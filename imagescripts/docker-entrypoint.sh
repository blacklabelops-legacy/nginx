#!/bin/bash

set -o errexit

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

if [ -n "${DELAYED_START}" ]; then
  sleep ${DELAYED_START}
fi

nginx_main_config_file="/opt/nginx/nginx.conf"

if [ "${NGINX_REDIRECT_PORT80}" = "true" ]; then
  source $CUR_DIR/port_redirect.sh
fi

if [ ! -f ${nginx_main_config_file}  ]; then
  source $CUR_DIR/create_config.sh
fi

if [ "$1" = 'nginx' ]; then
  exec nginx -c ${nginx_main_config_file} -g "daemon off;pid /var/run/nginx/nginx.pid;"
elif [[ "$1" == '-'* ]]; then
  exec nginx "$@"
else
  exec "$@"
fi
