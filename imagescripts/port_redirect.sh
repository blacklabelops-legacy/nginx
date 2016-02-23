#!/bin/bash

set -o errexit

NGINX_PORT_REDIRECT_PATTERN='https://$server_name$request_uri'

cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_

    server {
       listen       8080 default_server;
       listen       [::]:8080 default_server;
       server_name  _;
       return       301 ${NGINX_PORT_REDIRECT_PATTERN};
    }

_EOF_
