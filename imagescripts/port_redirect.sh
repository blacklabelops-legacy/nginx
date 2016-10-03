#!/bin/bash

set -o errexit

NGINX_PORT_REDIRECT_PATTERN='https://$server_name$request_uri'

PORT_REDIRECT_FILE=${NGINX_DIRECTORY}/conf.d/portRedirect.conf

cat > ${PORT_REDIRECT_FILE} <<_EOF_
_EOF_

for (( x=1; ; x++ ))
do
  VAR_NGINX_SERVER_NAME="SERVER${x}SERVER_NAME"

  if [ ! -n "${!VAR_NGINX_SERVER_NAME}" ]; then
    break
  fi

  NGINX_SERVER_NAME="_"

  if [ -n "${!VAR_NGINX_SERVER_NAME}" ]; then
    NGINX_SERVER_NAME=${!VAR_NGINX_SERVER_NAME}
  fi

  cat >> ${PORT_REDIRECT_FILE} <<_EOF_

    server {
       listen       80;
       listen       [::]:80;
       server_name  ${NGINX_SERVER_NAME};
       return       301 ${NGINX_PORT_REDIRECT_PATTERN};
    }

_EOF_
done

cat ${PORT_REDIRECT_FILE}
