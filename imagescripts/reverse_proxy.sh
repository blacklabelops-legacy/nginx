#!/bin/bash

set -o errexit

for (( i = 1; ; i++ ))
do
  VAR_REVERSE_PROXY_LOCATION="$1REVERSE_PROXY_LOCATION$i"
  VAR_REVERSE_PROXY_PASS="$1REVERSE_PROXY_PASS$i"
  VAR_REVERSE_PROXY_BUFFERING="$1REVERSE_PROXY_BUFFERING$i"
  VAR_REVERSE_PROXY_BUFFERS="$1REVERSE_PROXY_BUFFERS$i"
  VAR_REVERSE_PROXY_BUFFERS_SIZE="$1REVERSE_PROXY_BUFFERS_SIZE$i"
  VAR_REVERSE_PROXY_HOST="$1SERVER_NAME"

  if [ ! -n "${!VAR_REVERSE_PROXY_LOCATION}" ]; then
    break
  fi

  NGINX_PROXY_LOCATION=${!VAR_REVERSE_PROXY_LOCATION}
  NGINX_PROXY_PASS=${!VAR_REVERSE_PROXY_PASS}
  NGINX_PROXY_BUFFERING=${!VAR_REVERSE_PROXY_BUFFERING}
  NGINX_PROXY_BUFFERS=${!VAR_REVERSE_PROXY_BUFFERS}
  NGINX_PROXY_BUFFERS_SIZE=${!VAR_REVERSE_PROXY_BUFFERS_SIZE}
  NGINX_PROXY_HOST=${!VAR_REVERSE_PROXY_HOST}

  REVERSE_PROXY_REDIRECT_PATTERN='$scheme://$host/'

  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        location ${NGINX_PROXY_LOCATION} {
_EOF_

  if [ -n "${NGINX_PROXY_PASS}" ]; then
    cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
          proxy_pass ${NGINX_PROXY_PASS};
          proxy_redirect ${NGINX_PROXY_PASS} ${REVERSE_PROXY_REDIRECT_PATTERN};
_EOF_
  fi

  if [ -n "${NGINX_PROXY_HOST}" ]; then
    cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
          proxy_set_header Host ${NGINX_PROXY_HOST};
_EOF_
  fi

  if [ -n "${NGINX_PROXY_BUFFERING}" ]; then
    cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
          proxy_buffering ${NGINX_PROXY_BUFFERING};
_EOF_
  fi

  if [ -n "${NGINX_PROXY_BUFFERS}" ]; then
    cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
          proxy_buffers ${NGINX_PROXY_BUFFERS};
_EOF_
  fi

  if [ -n "${NGINX_PROXY_BUFFERS_SIZE}" ]; then
    cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
          proxy_buffer_size ${NGINX_PROXY_BUFFERS_SIZE};
_EOF_
  fi

  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        }
_EOF_
done
