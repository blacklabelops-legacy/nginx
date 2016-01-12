#!/bin/bash

set -o errexit

NGINX_PROXY_LOCATION=${REVERSE_PROXY_LOCATION}
NGINX_PROXY_PASS=${REVERSE_PROXY_PASS}
NGINX_PROXY_BUFFERING=${REVERSE_PROXY_BUFFERING}
NGINX_PROXY_BUFFERS=${REVERSE_PROXY_BUFFERS}
NGINX_PROXY_BUFFERS_SIZE=${REVERSE_PROXY_BUFFERS_SIZE}

if [ -n "${REVERSE_PROXY_LOCATION}" ]; then

  cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
        location ${NGINX_PROXY_LOCATION} {
_EOF_

  if [ -n "${NGINX_PROXY_PASS}" ]; then
    cat >> ${NGINX_DIRECTORY}/nginx.conf <<_EOF_
          proxy_pass ${NGINX_PROXY_PASS};
          proxy_redirect $scheme://$host:$server_port/ ${NGINX_PROXY_LOCATION};
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
fi
