#!/bin/bash -x

set -o errexit

if [ -n "${DELAYED_START}" ]; then
  sleep ${DELAYED_START}
fi

if [ ! -f "/home/nginx/nginx.conf" ]; then
  source /opt/nginx-scripts/create_config.sh
fi

if [ "$1" = 'nginx' ]; then
  nginx -c ${NGINX_DIRECTORY}/nginx.conf -g "daemon off;"
fi

exec "$@"
