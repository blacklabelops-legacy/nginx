#!/bin/bash -x

set -o errexit

if [ -n "${DELAYED_START}" ]; then
  sleep ${DELAYED_START}
fi

cat > ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /home/nginx/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /opt/nginx/conf.d/*.conf;
_EOF_

if [ -n "${SERVER1REVERSE_PROXY_LOCATION1}" ]; then
  source /opt/nginx-scripts/custom_server.sh
else
  source /opt/nginx-scripts/default_server.sh
fi

cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
}
_EOF_

cat ${NGINX_DIRECTORY}/nginx.conf

if [ "$1" = 'nginx' ]; then
  nginx -c ${NGINX_DIRECTORY}/nginx.conf -g "daemon off;"
fi

exec "$@"
