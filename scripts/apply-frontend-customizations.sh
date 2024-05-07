#!/usr/bin/env bash

# Applies the frontend extension customizations to the edu-sharing repository project and
# vice-versa.

set -e

# Relative location of the edu-sharing Git-repository root.
REPO_ROOT="../../repository"
# Frontend source directory, relative to $REPO_ROOT.
# Frontend source directory, relative to $REPO_ROOT.
FRONTEND_SRC="Frontend"
# Relative location of the source directory of extension frontend customizations.
EXTENSION_SRC="../repository/Frontend/src/main/ng"

# folders to obey and watch for changes
EXTENSION_FOLDERS=("src/" "projects/")

show_help_and_exit() {
    echo
    echo "Usage:"
    echo "        $0 put|get [--force] [--install]"
    echo
    echo "Modes:"
    echo "        put     Applies the contents of the extension directory to the edu-sharing"
    echo "                project folder."
    echo "        get     Deletes and repopulates the extension directory using unstaged changes"
    echo "                and untracked files in the edu-sharing project folder."
    echo
    echo "Options:"
    echo "        --force Overwrites uncommitted changes."
    echo "Options:"
    echo "        --install trigger npm install after put (useful if customer has a custom package.json)"
    exit 1
}

read_args() {
    if [[ "$#" -lt 1 ]]; then
        echo "Too few arguments"
        show_help_and_exit
    fi

    mode="$1"
    shift
    case "$mode" in
    put | get) true ;;
    *)
        echo "Invalid mode: $mode"
        show_help_and_exit
        ;;
    esac

    while [[ "$#" -gt 0 ]]; do
        case $1 in
        --force) force=1 ;;
        --install) install=1 ;;
        *)
            echo "Unknown parameter passed: $1"
            show_help_and_exit
            ;;
        esac
        shift
    done
}

confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
    [yY][eE][sS] | [yY])
        true
        ;;
    *)
        false
        ;;
    esac
}

check_git_frontend() {
    if [[ $(cd "$REPO_ROOT" && git status --porcelain) ]]; then
        if [[ "$force" == 1 ]]; then
            (
                cd "$REPO_ROOT"
                git status --short
                echo
                confirm "RESET all modified files and DELETE untracked files? [y/N]"
                git reset --hard
                git clean -df
            )
        else
            echo "Git repo is not clean. Please commit any changes."
            echo "Use '--force' to overwrite any uncommitted changes. (BE CAREFUL!)"
            exit 1
        fi
    fi
}

check_git_extension() {
    if [[ $(git status --porcelain "$EXTENSION_SRC") ]]; then
        if [[ "$force" == 1 ]]; then
            (
                git status --short "$EXTENSION_SRC"
                echo
                confirm "OVERWRITE the extension directory, LOOSING ALL uncommitted changes? [y/N]"
            )
        else
            echo "Extension dir contains uncommitted changes. Please commit any changes."
            echo "Use '--force' to overwrite any uncommitted changes. (BE CAREFUL!)"
            exit 1
        fi
    fi
}

put() {
  for i in "${EXTENSION_FOLDERS[@]}"
      do
         cp -r --verbose "$EXTENSION_SRC/$i." "$REPO_ROOT/$FRONTEND_SRC/$i"
  done
  if [[ "$install" == 1 ]]; then
    pushd $REPO_ROOT/$FRONTEND_SRC
    mv src/app/extension/package.json src/app/extension/package.json.bak
    # clear devDependencies since they might have internal repositories that are not available / configured
    jq 'del(.devDependencies)' src/app/extension/package.json.bak > src/app/extension/package.json
    npm i --no-package-lock
    mv src/app/extension/package.json.bak src/app/extension/package.json
  fi
}

get() {
    for i in "${EXTENSION_FOLDERS[@]}"
    do
      rm -rf "$EXTENSION_SRC/$i"
      mkdir "$EXTENSION_SRC/$i"
    done
    pushd "$REPO_ROOT" >/dev/null
    files=$(git add -A -n "$FRONTEND_SRC" | sed "s|^add '$FRONTEND_SRC/\(.*\)'$|\1|")
    submodule_files=$(git submodule foreach --quiet 'git add -A -n | sed "s|^add '"'"'\(.*\)'"'"'$|$name/\1|" | sed "s|^'$FRONTEND_SRC'/\(.*\)|\1|"')
    popd >/dev/null
    (echo "$files" && echo "$submodule_files") | while read file; do
        echo $file
        if [[ ! -z "$file" && ! -d "$REPO_ROOT/$FRONTEND_SRC/$file" ]]; then
            install -D --mode=644 "$REPO_ROOT/$FRONTEND_SRC/$file" "$EXTENSION_SRC/$file"
        fi
    done
}

main() {
    cd "$(dirname "$0")"
    read_args "$@"
    if [[ $mode == "put" ]]; then
        check_git_frontend
        put
    elif [[ $mode == "get" ]]; then
        check_git_extension
        get
    fi
}

main "$@"