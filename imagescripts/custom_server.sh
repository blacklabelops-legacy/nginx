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
NGINX_CERTIFICATE_TRUSTED=""

if [ -n "${CERTIFICATE_FILE}" ]; then
  NGINX_CERTIFICATE_FILE=${CERTIFICATE_FILE}
fi

if [ -n "${CERTIFICATE_KEY}" ]; then
  NGINX_CERTIFICATE_KEY=${CERTIFICATE_KEY}
fi

if [ -n "${CERTIFICATE_TRUSTED}" ]; then
  NGINX_CERTIFICATE_TRUSTED=${CERTIFICATE_TRUSTED}
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

if [ -n "$NGINX_CERTIFICATE_TRUSTED" ]; then
  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        ssl_trusted_certificate ${NGINX_CERTIFICATE_TRUSTED};
_EOF_
fi

if [ -n "$CERTIFICATE_DNAME" ] && [ "${NGINX_HTTPS_ENABLED}" = 'true' ]; then
  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;
_EOF_
fi

if [ "${LETSENCRYPT_CERTIFICATES}" = 'true' ]; then
  if [ ! -f "/opt/nginx/dhparam.pem" ]; then
    openssl dhparam -out /opt/nginx/dhparam.pem 2048
  fi
  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        ssl_session_timeout 1d;
        ssl_session_cache shared:SSL:50m;

        # Diffie-Hellman parameter for DHE ciphersuites, recommended 2048 bits
        # Generate with:
        #   openssl dhparam -out /etc/nginx/dhparam.pem 2048
        ssl_dhparam /opt/nginx/dhparam.pem;

        # What Mozilla calls "Intermediate configuration"
        # Copied from https://mozilla.github.io/server-side-tls/ssl-config-generator/
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
        ssl_prefer_server_ciphers on;

        # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
        add_header Strict-Transport-Security max-age=15768000;

        # OCSP Stapling
        # fetch OCSP records from URL in ssl_certificate and cache them
        ssl_stapling on;
        ssl_stapling_verify on;
_EOF_
fi
