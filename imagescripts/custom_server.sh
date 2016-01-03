#!/bin/bash

set -o errexit

NGINX_SERVER_NAME="_"

NGINX_HTTP_ENABLED="true"
NGINX_HTTPS_ENABLED="false"

if [ -n "${SERVER_NAME}" ]; then
  NGINX_SERVER_NAME=${SERVER_NAME}
fi

if [ -n "${HTTP_ENABLED}" ]; then
  NGINX_HTTP_ENABLED=${HTTP_ENABLED}
fi

if [ -n "${HTTPS_ENABLED}" ]; then
  NGINX_HTTPS_ENABLED=${HTTPS_ENABLED}
fi

NGINX_CERTIFICATE_FILE="${NGINX_DIRECTORY}/keys/server.crt"
NGINX_CERTIFICATE_KEY="${NGINX_DIRECTORY}/keys/server.key"

if [ -n "${CERTIFICATE_FILE}" ]; then
  NGINX_CERTIFICATE_FILE=${CERTIFICATE_FILE}
fi

if [ -n "${CERTIFICATE_KEY}" ]; then
  NGINX_CERTIFICATE_KEY=${CERTIFICATE_KEY}
fi

cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
    server {
_EOF_

if [ "${NGINX_HTTP_ENABLED}" = 'true' ]; then
  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        listen       8080 default_server;
        listen       [::]:8080 default_server;
_EOF_
fi

if [ "${NGINX_HTTPS_ENABLED}" = 'true' ]; then
  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        listen              44300 ssl;
        keepalive_timeout   70;
_EOF_
fi

cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        server_name  ${NGINX_SERVER_NAME};

        # Load configuration files for the default server block.
        include /opt/nginx/default.d/*.conf;

_EOF_

if [ -n "$CERTIFICATE_DNAME" ] && [ "${NGINX_HTTPS_ENABLED}" = 'true' ]; then
  if [ ! -f "${NGINX_DIRECTORY}/keys/server.key" ]; then
    openssl req -subj "${CERTIFICATE_DNAME}" -new -newkey rsa:4096 -days 365 -nodes -x509 -keyout ${NGINX_DIRECTORY}/keys/server.key -out ${NGINX_DIRECTORY}/keys/server.crt
  fi
  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        ssl_certificate     ${NGINX_CERTIFICATE_FILE};
        ssl_certificate_key ${NGINX_CERTIFICATE_KEY};
_EOF_
fi

if [ ! -n "$CERTIFICATE_DNAME" ] && [ "${NGINX_HTTPS_ENABLED}" = 'true' ]; then
  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        ssl_certificate     ${NGINX_CERTIFICATE_FILE};
        ssl_certificate_key ${NGINX_CERTIFICATE_KEY};
_EOF_
fi

if [ "${NGINX_HTTPS_ENABLED}" = 'true' ]; then
  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;
_EOF_
fi
