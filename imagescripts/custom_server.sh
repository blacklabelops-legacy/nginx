#!/bin/bash

set -o errexit

for (( j=1; ; j++ ))
do
  configFile=${NGINX_DIRECTORY}/conf.d/server${j}.conf
  VAR_TESTPASS="SERVER${j}REVERSE_PROXY_LOCATION1"
  VAR_NGINX_SERVER_NAME="SERVER${j}SERVER_NAME"
  VAR_NGINX_HTTP_ENABLED="SERVER${j}HTTP_ENABLED"
  VAR_NGINX_HTTPS_ENABLED="SERVER${j}HTTPS_ENABLED"
  VAR_NGINX_CERTIFICATE_FILE="SERVER${j}CERTIFICATE_FILE"
  VAR_NGINX_CERTIFICATE_KEY="SERVER${j}CERTIFICATE_KEY"
  VAR_NGINX_CERTIFICATE_TRUSTED="SERVER${j}CERTIFICATE_TRUSTED"
  VAR_NGINX_CERTIFICATE_DNAME="SERVER${j}CERTIFICATE_DNAME"
  VAR_LETSENCRYPT_CERTIFICATES="SERVER${j}LETSENCRYPT_CERTIFICATES"

  if [ ! -n "${!VAR_TESTPASS}" ]; then
    break
  fi

  NGINX_SERVER_NAME="_"

  NGINX_HTTP_ENABLED="true"
  NGINX_HTTPS_ENABLED="false"

  if [ -n "${!VAR_NGINX_SERVER_NAME}" ]; then
    NGINX_SERVER_NAME=${!VAR_NGINX_SERVER_NAME}
  fi

  if [ -n "${!VAR_NGINX_HTTP_ENABLED}" ]; then
    NGINX_HTTP_ENABLED=${!VAR_NGINX_HTTP_ENABLED}
  fi

  if [ -n "${!VAR_NGINX_HTTPS_ENABLED}" ]; then
    NGINX_HTTPS_ENABLED=${!VAR_NGINX_HTTPS_ENABLED}
  fi

  NGINX_CERTIFICATE_FILE="${NGINX_DIRECTORY}/keys/server.crt"
  NGINX_CERTIFICATE_KEY="${NGINX_DIRECTORY}/keys/server.key"
  NGINX_CERTIFICATE_TRUSTED=""

  if [ -n "${!VAR_NGINX_CERTIFICATE_FILE}" ]; then
    NGINX_CERTIFICATE_FILE=${!VAR_NGINX_CERTIFICATE_FILE}
  fi

  if [ -n "${!VAR_NGINX_CERTIFICATE_KEY}" ]; then
    NGINX_CERTIFICATE_KEY=${!VAR_NGINX_CERTIFICATE_KEY}
  fi

  if [ -n "${!VAR_NGINX_CERTIFICATE_TRUSTED}" ]; then
    NGINX_CERTIFICATE_TRUSTED=${!VAR_NGINX_CERTIFICATE_TRUSTED}
  fi

  NGINX_CERTIFICATE_DNAME=${!VAR_NGINX_CERTIFICATE_DNAME}
  NGINX_LETSENCRYPT_CERTIFICATES=${!VAR_LETSENCRYPT_CERTIFICATES}

  cat >> ${configFile} <<_EOF_
    server {
_EOF_

  if [ "${NGINX_HTTP_ENABLED}" = 'true' ]; then
    if [ "${NGINX_SERVER_NAME}" = '_' ]; then
      cat >> ${configFile} <<_EOF_
        listen       80 default_server;
        listen       [::]:80 default_server;
_EOF_
    else
      cat >> ${configFile} <<_EOF_
        listen       80;
        listen       [::]:80;
_EOF_
    fi
  fi

  if [ "${NGINX_HTTPS_ENABLED}" = 'true' ]; then
    cat >> ${configFile} <<_EOF_
        listen              443 ssl;
        keepalive_timeout   0;
_EOF_
  fi

  cat >> ${configFile} <<_EOF_
        server_name  ${NGINX_SERVER_NAME};
_EOF_

  if [ -n "$NGINX_CERTIFICATE_DNAME" ] && [ "${NGINX_HTTPS_ENABLED}" = 'true' ]; then
    if [ ! -f "${NGINX_DIRECTORY}/keys/server.key" ]; then
      openssl req -subj "${NGINX_CERTIFICATE_DNAME}" -new -newkey rsa:4096 -days 365 -nodes -x509 -keyout ${NGINX_DIRECTORY}/keys/server.key -out ${NGINX_DIRECTORY}/keys/server.crt
    fi
    cat >> ${configFile} <<_EOF_
        ssl_certificate     ${NGINX_CERTIFICATE_FILE};
        ssl_certificate_key ${NGINX_CERTIFICATE_KEY};
_EOF_
  fi

  if [ ! -n "$NGINX_CERTIFICATE_DNAME" ] && [ "${NGINX_HTTPS_ENABLED}" = 'true' ]; then
    cat >> ${configFile} <<_EOF_
        ssl_certificate     ${NGINX_CERTIFICATE_FILE};
        ssl_certificate_key ${NGINX_CERTIFICATE_KEY};
_EOF_
  fi

  if [ -n "$NGINX_CERTIFICATE_TRUSTED" ]; then
    cat >> ${configFile} <<_EOF_
        ssl_trusted_certificate ${NGINX_CERTIFICATE_TRUSTED};
_EOF_
  fi

  if [ -n "$NGINX_CERTIFICATE_DNAME" ] && [ "${NGINX_HTTPS_ENABLED}" = 'true' ]; then
    cat >> ${configFile} <<_EOF_
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;
_EOF_
  fi

  if [ "${NGINX_LETSENCRYPT_CERTIFICATES}" = 'true' ]; then
    if [ ! -f "/home/nginx/dhparam.pem" ]; then
      openssl dhparam -out /home/nginx/dhparam.pem 2048
    fi
    cat >> ${configFile} <<_EOF_
        ssl_session_timeout 1d;
        ssl_session_cache shared:SSL:50m;

        # Diffie-Hellman parameter for DHE ciphersuites, recommended 2048 bits
        # Generate with:
        #   openssl dhparam -out /etc/nginx/dhparam.pem 2048
        ssl_dhparam /home/nginx/dhparam.pem;

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

        location ^~ /.well-known/acme-challenge/ {
          default_type  "text/plain";
          root          /var/www/letsencrypt;
        }

_EOF_
        mkdir -p /var/www/letsencrypt
  fi

  source $CUR_DIR/reverse_proxy.sh SERVER${j} ${j}

  cat >> ${configFile} <<_EOF_
      # Load configuration files for the default server block.
      include ${NGINX_DIRECTORY}/conf.d/server${j}/*.conf;

    }

_EOF_
  cat ${configFile}
done
