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

delete deploy/docker/build/activemq
delete deploy/docker/build/apache_exporter
delete deploy/docker/build/mailcatcher
delete deploy/docker/build/minideb
delete deploy/docker/build/postgresql
delete deploy/docker/build/postgresql_exporter
delete deploy/docker/build/redis
delete deploy/docker/build/rediscluster
delete deploy/docker/build/redis_exporter
delete deploy/docker/build/varnish
delete deploy/docker/build/varnish_exporter

delete deploy/docker/compose/src/main/compose/0_edusharing-common.yml
delete deploy/docker/compose/src/main/compose/0_edusharing-debug.yml
delete deploy/docker/compose/src/main/compose/0_edusharing-productive.yml
delete deploy/docker/compose/src/main/compose/0_edusharing-remote.yml

delete deploy/docker/helm/postgresql
delete deploy/docker/helm/rediscluster

delete deploy/docker/repository
delete deploy/docker/services
