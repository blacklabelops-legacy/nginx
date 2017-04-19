#!/bin/bash

set -o errexit

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

if [ -n "${DELAYED_START}" ]; then
  sleep ${DELAYED_START}
fi

nginx_main_config_file=${NGINX_DIRECTORY}"/nginx.conf"

if [ ! -f ${nginx_main_config_file}  ]; then
  rm -rf ${NGINX_DIRECTORY}/conf.d/*
  if [ "${NGINX_REDIRECT_PORT80}" = 'true' ]; then
    source $CUR_DIR/port_redirect.sh
  fi
  source $CUR_DIR/create_config.sh
fi

if [ "$1" = 'nginx' ]; then
  exec nginx -g "daemon off;"
elif [[ "$1" == '-'* ]]; then
  exec nginx "$@"
else
  exec "$@"
fi
