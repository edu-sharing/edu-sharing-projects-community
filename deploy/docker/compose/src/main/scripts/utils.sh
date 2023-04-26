#!/bin/bash
set -e
set -o pipefail

export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-$(basename $(pwd))}"

case "$(uname)" in
MINGW*)
  COMPOSE_EXEC="winpty docker compose"
  ;;
*)
  COMPOSE_EXEC="docker compose"
  ;;
esac

export COMPOSE_EXEC

export CLI_CMD="$0"
export CLI_OPT1="$1"
shift || true

ROOT_PATH="$(
  cd "$(dirname ".")"
  pwd -P
)"
export ROOT_PATH

pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)" >/dev/null || exit

COMPOSE_DIR="."

[[ -f ".env" ]] && [[ ! "${COMPOSE_DIR}/.env" -ef "./.env" ]] && {
  cp -f ".env" "${COMPOSE_DIR}"
}

pushd "${COMPOSE_DIR}" >/dev/null || exit

if [[ -f ".env" ]]; then
  source .env
else
  REPOSITORY_SERVICE_HOST="127.0.0.1"
  SERVICES_RENDERING_SERVICE_HOST="127.0.0.1"
fi

info() {
  echo ""
  echo "#########################################################################"
  echo ""
  echo "  edu-sharing repository:"
  echo ""
  echo "    ${REPOSITORY_SERVICE_PROT:-http}://${REPOSITORY_SERVICE_HOST:-repository.127.0.0.1.nip.io}:${REPOSITORY_SERVICE_PORT:-8100}${REPOSITORY_SERVICE_PATH:-/edu-sharing}/"
  echo ""
  echo "    username: admin"
  echo "    password: ${REPOSITORY_SERVICE_ADMIN_PASS:-admin}"
  echo ""
  echo "  edu-sharing services:"
  echo ""
  echo "    rendering:"
  echo ""
  echo "      ${SERVICES_RENDERING_SERVICE_PROT:-http}://${SERVICES_RENDERING_SERVICE_HOST:-rendering.services.127.0.0.1.nip.io}:${SERVICES_RENDERING_SERVICE_PORT:-9100}${SERVICES_RENDERING_SERVICE_PATH:-/esrender}/admin/"
  echo ""
  echo "      username: ${SERVICES_RENDERING_DATABASE_USER:-rendering}"
  echo "      password: ${SERVICES_RENDERING_DATABASE_PASS:-rendering}"
  echo ""
  echo "#########################################################################"
  echo ""
  echo "  All exposed ports are bound to network address: ${COMMON_BIND_HOST:-127.0.0.1}."
  echo ""
  echo "#########################################################################"
  echo ""
  echo "  If you need to customize the installation, then:"
  echo ""
  echo "    - make a copy of \".env.sample\" to \".env\""
  echo "    - comment out and update relevant entities inside \".env\""
  echo ""
  echo "#########################################################################"
  echo ""
  echo ""
}

logs() {
  $COMPOSE_EXEC \
    logs -f $@ || exit
}

terminal() {
  $COMPOSE_EXEC \
    exec -u root -it $1 /bin/bash || exit
}

ps() {
  $COMPOSE_EXEC \
    ps || exit
}

start() {
  $COMPOSE_EXEC \
    pull || exit

  $COMPOSE_EXEC \
    up -d $@ || exit
}

stop() {
  $COMPOSE_EXEC \
    stop $@ || exit
}

remove() {
  read -p "Are you sure you want to continue? [y/N] " answer
  case ${answer:0:1} in
  y | Y)
    $COMPOSE_EXEC \
      down || exit
    ;;
  *)
    echo Canceled.
    ;;
  esac
}

purge() {
  read -p "Are you sure you want to continue? [y/N] " answer
  case ${answer:0:1} in
  y | Y)
    $COMPOSE_EXEC \
      down -v || exit
    ;;
  *)
    echo Canceled.
    ;;
  esac
}

backup() {

  solr=
  elastic=
  repo=
  hotbackup=
  keep=
  while true ; do
    flag="$1"
    if [[ -z $flag ]] ; then
        echo "Please use a backup option. See --help for more information"
        exit 1;
    fi

    case "$flag" in
      --all) solr=true; elastic=true; repo=true ;;
      --repo) repo=true ;;
      --elastic) elastic=true ;;
      --solr) solr=true ;;
      --hot-backup) hotBackup=true ;;
      --keep)
        shift || break;
        keep=$1;
        if [[ !  $keep =~ ^[0-9]+$ ]] ; then
          echo "ERROR: --keep needs to be followed by a number"
          exit 1;
        fi
        ;;
      --help)
        echo "backup [Options...] <backup storage path>"
        echo "Options:"
        echo "  --all              Backup repository, elastic search index and apache solr index"
        echo "  --repo             Backup repository including binaries and databases"
        echo "  --elastic          Backup elastic search index"
        echo "  --solr             Backup apache solr index"
        echo "  --keep <number>    Removes older backups but keeps n numbers"
        echo "  --hot-backup       Create a backup without stopping the systems"
        echo "                     This can lead to missing data and corrupted index in terms of the overall system"
        echo "                     Backups of each component are therefore still valid."
        exit 0
        ;;
      -*) echo "Unknown option, See --help for more information"; exit 1;;
      *) break ;;
    esac
    shift || echo "Missing backup directory"
  done

  date="$(date +%d-%m-%Y"_"%H_%M_%S)"
  backupRootDir="$(realpath "$1")"
  backupDir="$backupRootDir/$date"
  mkdir -p "$backupDir"

  if [[ -z $hotBackup ]] ; then
    echo "pause repository and elastic tracker services"
    $COMPOSE_EXEC pause repository-search-elastic-tracker repository-service || true
  fi

  if [[ -n $repo ]] ; then
    echo "backup postgres"
    $COMPOSE_EXEC exec -t repository-database sh -c "export PGPASSWORD=${REPOSITORY_DATABASE_PASS:-repository}; pg_dumpall --clean -U postgres | gzip" >"$backupDir/repository-db.gz && exit -1" || {
      rm -rf "$backupDir"
      echo "ERROR on creating postgres dump"
      exit 1
    }

    echo "backup binaries"
    docker run \
      --rm \
      --volumes-from "$(docker compose ps repository-service -q -a)" \
      -v "$backupDir":/backup \
      bitnami/minideb:bullseye \
      bash -c '
        cd /opt/alfresco/alf_data \
        && tar cvf /backup/binaries.tar .
      ' || {
        rm -rf "$backupDir"
        echo "ERROR on copying binaries"
        exit 1
      }
  fi

  if [[ -n $solr ]] ; then
    echo "### backup solr4"
    docker run \
      --rm \
      --volumes-from "$(docker compose ps repository-search-solr4 -q)" \
      -v "$backupDir":/backup \
      --network "$(docker inspect "$(docker compose ps repository-search-solr4 -q)" -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s" $net}}{{end}}')" \
      bitnami/minideb:bullseye \
      bash -c '
        apt update \
        && apt install -y wget curl xmlstarlet \
        && wget -qo- "http://repository-search-solr4:8080/solr4/alfresco/replication?command=backup&location=/opt/alfresco/alf_data/backup&name=alfresco" \
        && wget -qo- "http://repository-search-solr4:8080/solr4/archive/replication?command=backup&location=/opt/alfresco/alf_data/backup&name=archive"  \
        && while [[ "success" != $(curl -s "http://repository-search-solr4:8080/solr4/alfresco/replication?command=details" | xmlstarlet sel -t -v  "//lst[@name=\"backup\"]/str[@name=\"status\"]") ]] ; do echo "wait for solr alfresco backup..."; sleep 500; done \
        && while [[ "success" != $(curl -s "http://repository-search-solr4:8080/solr4/archive/replication?command=details" | xmlstarlet sel -t -v  "//lst[@name=\"backup\"]/str[@name=\"status\"]") ]] ; do echo "wait for solr archive backup..."; sleep 500; done \
        && echo "compress backup:" \
        && cd /opt/alfresco/alf_data/backup \
        && tar cvf /backup/solr4.tar . \
        && echo "cleanup backup folder:" \
        && cd .. \
        && rm -rf backup
      ' || {
        rm -rf "$backupDir"
        echo "ERROR on creating solr4 dump"
        exit 1
      }
  fi

  if [[ -n $elastic ]] ; then
    echo "### backup elastic"
    docker run \
      --rm \
      -ti \
      -v "$backupDir":/tmp --network "$(docker inspect "$(docker compose ps repository-search-elastic-index -q)" -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s" $net}}{{end}}')" \
      elasticdump/elasticsearch-dump \
      --input=http://repository-search-elastic-index:9200/workspace \
      --output=$ \
      | gzip > "$backupDir/elastic_workspace.gz" || {
        rm -rf "$backupDir"
        echo "ERROR on creating elastic workspace dump"
        exit 1
      }

    docker run \
      --rm \
      -ti \
      -v "$backupDir":/tmp --network "$(docker inspect "$(docker compose ps repository-search-elastic-index -q)" -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s" $net}}{{end}}')" \
      elasticdump/elasticsearch-dump \
      --input=http://repository-search-elastic-index:9200/transactions \
      --output=$ \
      | gzip > "$backupDir/elastic_transactions.gz" || {
        rm -rf "$backupDir"
        echo "ERROR on creating elastic transactions dump"
        exit 1
      }
  fi


  if [[ -z $hotBackup ]] ; then
    echo "### unpause repository and elastic tracker services"
    $COMPOSE_EXEC unpause repository-search-elastic-tracker repository-service
  fi

  if [[ -n $keep ]] ; then
    echo "### delete older backups but keep latest $keep"
    find "$backupRootDir" -maxdepth 1 -mindepth 1 -type d -printf '%T@ %p\0' \
      | sort -r -z -n \
      | awk "BEGIN { RS=\"\0\"; ORS=\"\0\"; FS=\"\" } NR > $keep { sub(\"^[0-9]*(.[0-9]*)? \", \"\"); print }" \
      | xargs -0 rm -rf
  fi
}

restore() {

  backupDir="$(realpath "${1:?No Backup path defined. Please provide a backup path}")"
  if [[ ! -d "$backupDir" ]]; then
    echo "Backup directory  \"$backupDir\" not found"
    exit 1
  fi

  container=
  repo=
  solr=
  elastic=
  if [[ -f "$backupDir/binaries.tar" ]] || [[ -f "$backupDir/repository-db.gz" ]] ; then
    if [[ ! -f "$backupDir/binaries.tar" ]]; then
      echo "Backup directory doesn't contains a binaries.tar!"
      exit 1
    fi

    if [[ ! -f "$backupDir/repository-db.gz" ]]; then
      echo "Backup directory doesn't contains a repository-db.gz file!"
      exit 1
    fi

    repo=true
    container="$container  repository-service"
  fi

  if [[ -f "$backupDir/solr4.tar" ]]; then
    solr=true
    container="repository-search-solr4 $container"
  fi

  if [[ -f "$backupDir/elastic_workspace.gz" ]] || [[ -f "$backupDir/elastic_transactions.gz" ]]; then
    elastic=true
    container="repository-search-elastic-tracker $container"
  fi

  if [[ -z $repo ]] && [[ -z $solr ]]  && [[ -z $elastic ]]; then
    echo "Nothing to restore"
    exit 1
  fi

  echo "### stop repository"
  $COMPOSE_EXEC stop $container

  if [[ -n $repo ]] ; then
    echo "### restore binaries"
    docker run \
      --rm \
      --volumes-from "$(docker compose ps repository-service -q -a)" \
      -v "$backupDir":/backup \
      bitnami/minideb:bullseye \
      bash -c '
        cd /opt/alfresco/alf_data \
        && find . -mindepth 1 -delete || true \
        && tar xvf /backup/binaries.tar
      '

    echo "### restore postgres"
    gunzip <"$backupDir/repository-db.gz" | $COMPOSE_EXEC exec -T repository-database sh -c "export PGPASSWORD=${REPOSITORY_DATABASE_PASS:-repository}; psql -U postgres"
  fi

  if [[ -n $solr ]] ; then
    echo "### restore solr4"
    docker run \
      --rm \
      --volumes-from "$(docker compose ps repository-search-solr4 -q -a)" \
      -v "$backupDir":/backup \
      bitnami/minideb:bullseye \
      bash -c '
        rm -rf /opt/alfresco/alf_data/solr4/index || true \
        rm -rf /opt/alfresco/alf_data/solr4/content || true \
        rm -rf /opt/alfresco/alf_data/solr4/model || true \
        && mkdir -p /opt/alfresco/alf_data/solr4/index \
        && cd /opt/alfresco/alf_data/solr4/index \
        && tar xvf /backup/solr4.tar \
        && mv snapshot.alfresco alfresco \
        && mv snapshot.archive archive
      '
  fi

  if [[ -n $elastic ]] ; then
    echo "backup elastic"
    if [[ -f "$backupDir/elastic_workspace.gz" ]] ; then
      docker run \
        --rm \
        -v "$backupDir":/tmp --network "$(docker inspect "$(docker compose ps repository-search-elastic-index -q -a)" -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s" $net}}{{end}}')" \
        elasticdump/elasticsearch-dump \
        --input=/tmp/elastic_workspace.gz \
        --output=http://repository-search-elastic-index:9200/workspace \
        --type=data \
        --fsCompress

    fi

    if [[ -f "$backupDir/elastic_transactions.gz" ]] ; then
      docker run \
        --rm \
        -v "$backupDir":/tmp --network "$(docker inspect "$(docker compose ps repository-search-elastic-index -q -a)" -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s" $net}}{{end}}')" \
        elasticdump/elasticsearch-dump \
        --input=/tmp/elastic_transactions.gz  \
        --output=http://repository-search-elastic-index:9200/transactions \
        --type=data \
        --fsCompress
    fi
  fi

  echo "### start repo"
  $COMPOSE_EXEC start $container
}

case "${CLI_OPT1}" in
start)
  start $@ && info
  ;;
info)
  info
  ;;
logs)
  logs $@
  ;;
ps)
  ps
  ;;
stop)
  stop $@
  ;;
remove)
  remove
  ;;
purge)
  purge
  ;;
restart)
  stop $@ && start $@ && info
  ;;
terminal)
  terminal $@
  ;;
backup)
  backup $@
  ;;
restore)
  restore $@
  ;;
*)
  echo ""
  echo "Usage: ${CLI_CMD} [option]"
  echo ""
  echo "options:"
  echo ""
  echo "  - start [Service...]                 startup containers"
  echo "  - restart [Service...]               stops and starts containers"
  echo ""
  echo "  - info                               show information"
  echo "  - logs [Service...]                  show logs"
  echo "  - ps                                 show containers"
  echo ""
  echo "  - stop [Service...]                  stop all containers"
  echo "  - remove                             remove all containers"
  echo "  - purge                              remove all containers and volumes"
  echo ""
  echo "  - terminal [service]                 open container bash as root"
  echo ""
  echo "  - backup [Options] <backup path>     create a backup at the given backup location"
  echo "  - restore <backup path>              restore a backup from the given location"
  echo ""
  ;;
esac

popd >/dev/null || exit
popd >/dev/null || exit
