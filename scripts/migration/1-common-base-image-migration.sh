#!/bin/bash

set -e
set -o pipefail

if [[ ! -d "$1" ]] ; then
  echo "ERROR Path not found: $1"
  exit 1
fi

cd "$1"

delete() {
  if [[ -d "$1" ]] ; then
    echo "delete $1"
    rm -rf "$1"
  elif [[ -f "$1" ]] ; then
    echo "delete $1"
    rm -f "$1"
  fi
}

delete deploy/docker/build

delete deploy/docker/compose/src/main/compose/0_edusharing-common.yml
delete deploy/docker/compose/src/main/compose/0_edusharing-debug.yml
delete deploy/docker/compose/src/main/compose/0_edusharing-productive.yml
delete deploy/docker/compose/src/main/compose/0_edusharing-remote.yml

delete deploy/docker/helm/bundle
delete deploy/docker/helm/postgresql
delete deploy/docker/helm/rediscluster

delete deploy/docker/repository
delete deploy/docker/services
