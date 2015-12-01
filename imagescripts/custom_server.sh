#!/bin/bash

set -o errexit

NGINX_SERVER_NAME="_"

if [ -n "${SERVER_NAME}" ]; then
  NGINX_SERVER_NAME=${SERVER_NAME}
fi

cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
    server {
        listen       8080 default_server;
        listen       [::]:8080 default_server;
        server_name  ${NGINX_SERVER_NAME};

        # Load configuration files for the default server block.
        include /opt/nginx/default.d/*.conf;
        
_EOF_
