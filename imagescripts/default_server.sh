#!/bin/bash

set -o errexit

nginx_use_ipv6="false"
nginx_http_port="80"

if [ -n "${NGINX_USE_IPV6}" ]; then
  nginx_use_ipv6=${NGINX_USE_IPV6}
fi

if [ -n "${NGINX_HTTP_PORT}" ]; then
  nginx_http_port=${NGINX_HTTP_PORT}
fi

cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
server {
_EOF_

if [ "${nginx_use_ipv6}" = 'true' ]; then
  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
  listen       [::]:${nginx_http_port} default_server;
_EOF_
else
  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
  listen       ${nginx_http_port} default_server;
_EOF_
fi

cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
  server_name  _;
  root         /usr/share/nginx/html;

  # Load configuration files for the default server block.
  include ${NGINX_DIRECTORY}/default.d/*.conf;

  location / {
  }

  error_page 404 /404.html;
    location = /40x.html {
  }

  error_page 500 502 503 504 /50x.html;
    location = /50x.html {
  }
}
_EOF_
