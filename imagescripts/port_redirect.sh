#!/bin/bash

set -o errexit

nginx_use_ipv6="false"
nginx_http_port="80"

if [ -n "${NGINX_IPV6_ENABLED}" ]; then
  nginx_use_ipv6=${NGINX_IPV6_ENABLED}
fi

if [ -n "${NGINX_HTTP_PORT}" ]; then
  nginx_http_port=${NGINX_HTTP_PORT}
fi

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
_EOF_

  if [ "${nginx_use_ipv6}" = 'true' ]; then
    cat >> ${PORT_REDIRECT_FILE} <<_EOF_
  listen       [::]:${nginx_http_port};
_EOF_
  else
    cat >> ${PORT_REDIRECT_FILE} <<_EOF_
  listen       ${nginx_http_port};
_EOF_
  fi

  cat >> ${PORT_REDIRECT_FILE} <<_EOF_
  server_name  ${NGINX_SERVER_NAME};
  return       301 ${NGINX_PORT_REDIRECT_PATTERN};
}
_EOF_
done

echo "${PORT_REDIRECT_FILE}:"
cat ${PORT_REDIRECT_FILE}
