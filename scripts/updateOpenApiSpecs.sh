#!/usr/bin/env bash

set -eo

SOURCE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

openApiFile="$SOURCE_PATH/../../repository/Backend/services/rest/api/src/main/resources/openapi.json"
curl -m 300 -H 'Accept: application/json' --user 'admin:admin' http://repository.127.0.0.1.nip.io:8100/edu-sharing/rest/openapi.json | jq -S . > "$openApiFile"
