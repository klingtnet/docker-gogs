#!/usr/bin/env bash

SCRIPT_ROOT=$(dirname ${BASH_SOURCE[0]})
GOGS_SHARE_PATH=${GOGS_SHARE_PATH:-${SCRIPT_ROOT}/share}
GOGS_SSH_PORT=${GOGS_SSH_PORT:-18022}
GOGS_HTTP_PORT=${GOGS_HTTP_PORT:-18000}

docker run --name docker-gogs --rm --volume ${GOGS_SHARE_PATH}:/home/gogs/share --publish ${GOGS_SSH_PORT}:22 --publish ${GOGS_HTTP_PORT}:8080 gogs /home/gogs/start.sh

