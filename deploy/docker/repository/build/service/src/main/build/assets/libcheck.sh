#!/bin/bash
[[ -n $DEBUG ]] && set -x
set -eu

########################################################################################################################
whitelist=(
  # swagger gen vs swagger usage conflict -> new api
  "swagger-annotations-1.6.6.jar:alf-lib"  # diff groupId
  "swagger-annotations-2.1.11.jar:alf-lib" # diff groupId
  "wss4j-1.6.19.jar:alf-lib" # axis-1.4
  "wss4j-1.5.12.jar:edu-lib" # axis-1.4
  "xmlsec-1.5.8.jar:alf-lib" # axis-1.4
  "xmlsec-1.4.5.jar:edu-lib" # axis-1.4
  "bsh-1.3.0.jar:alf-lib" # diff groupId
  "bsh-2.0b6.jar:alf-lib" # diff groupId
)

files=()
pushd tomcat/lib  >/dev/null || exit 1
while IFS='' read -r line; do files+=("$line"); done < <(ls | awk '{print $0 ":tomcat-lib"}')
popd >/dev/null


if [[  -d tomcat/webapps/alfresco/WEB-INF/lib ]] ; then
  pushd tomcat/webapps/alfresco/WEB-INF/lib  >/dev/null || exit 1
  while IFS='' read -r line; do files+=("$line"); done < <(ls | awk '{print $0 ":alf-lib"}')
  popd >/dev/null
fi

if [[  -d tomcat/webapps/edu-sharing/WEB-INF/lib ]] ; then
  pushd tomcat/webapps/edu-sharing/WEB-INF/lib  >/dev/null || exit 1
  while IFS='' read -r line; do files+=("$line"); done < <(ls | awk '{print $0 ":edu-lib"}')
  popd >/dev/null
fi

for file in "${whitelist[@]}" ; do
  files=("${files[@]/${file}}")
done

groupedFiles=()
while IFS='' read -r line; do groupedFiles+=("$line"); done < <(printf "%s\n" "${files[@]}" | sed 's|-[0-9.][0-9.]*[a-zA-Z0-9_]*\.jar:.*$||' | sort | uniq -c | sed 's| *||') #| sed 's| |:|g')

duplicates=()
for group in "${groupedFiles[@]}" ; do
  if [[ -n ${group##* } ]] && [[ ${group%% *} != 1 ]] ; then
    while IFS='' read -r line; do duplicates+=("$line"); done < <(echo "Multiple library versions of ${group##* } (${group%% *}) found:")
    while IFS='' read -r line; do duplicates+=("$line"); done < <(printf "%s\n" "${files[@]}" | grep "^${group##* }-[0-9.][0-9.]*[a-zA-Z0-9_]*\.jar:.*$")
    while IFS='' read -r line; do duplicates+=("$line"); done < <(echo "")
  fi
done

if [[ ${#duplicates[@]} != 0 ]] ; then
  echo "ERROR duplicated libraries found:"
  printf "%s\n" "${duplicates[@]}"
  exit 1
fi