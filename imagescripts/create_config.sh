#!/bin/bash

set -o errexit

NAMESERVER=$(cat /etc/resolv.conf | grep "nameserver" | tail -1 | awk '{print $2}' | tr '\n' ' ')
LOG_FORMAT='$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$http_x_forwarded_for"'

cat > ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
worker_processes auto;
error_log /dev/stdout info;

events {
    worker_connections 1024;
}

http {
    log_format  main  '${LOG_FORMAT}';

    access_log /dev/stdout;

    sendfile              on;
    tcp_nopush            on;
    tcp_nodelay           on;

    resolver ${NAMESERVER} ipv6=off valid=30s;
_EOF_

nginx_upload_size='100m'

if [ -n "${NGINX_MAX_UPLOAD_SIZE}" ]; then
  nginx_upload_size=${NGINX_MAX_UPLOAD_SIZE}
fi

cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
    client_max_body_size  ${nginx_upload_size};
_EOF_

cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
    keepalive_timeout     65;
    types_hash_max_size   2048;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include ${NGINX_DIRECTORY}/conf.d/*.conf;

_EOF_

if [ -n "${SERVER1REVERSE_PROXY_LOCATION1}" ]; then
  source $CUR_DIR/custom_server.sh
else
  source $CUR_DIR/default_server.sh
fi

cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
}
_EOF_

cat ${NGINX_DIRECTORY}/nginx.conf
