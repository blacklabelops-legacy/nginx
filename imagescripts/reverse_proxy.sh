#!/bin/bash

set -o errexit

function setApplicationHeaders() {
  local applicationId=$1
  local REVERSE_PROXY_HOST_HEADER='$host'
  local REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR='$proxy_add_x_forwarded_for'
  local REVERSE_PROXY_PROTO_HEADER='$scheme'
  local REVERSE_PROXY_UP_HEADER='$remote_addr'

  case "$applicationId" in
    confluence)
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_set_header X-Forwarded-Host ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-Server ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-For ${REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR};
_EOF_
      ;;
    jira)
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_set_header X-Forwarded-Host ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-Server ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-For ${REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR};
_EOF_
      ;;
    crowd)
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_set_header Host ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Real-IP ${REVERSE_PROXY_UP_HEADER};
          proxy_set_header X-Forwarded-for ${REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR};
          port_in_redirect off;
_EOF_
      ;;
    bitbucket)
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_set_header X-Forwarded-Host ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-Server ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-For ${REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR};
          proxy_set_header X-Real-IP ${REVERSE_PROXY_UP_HEADER};
_EOF_
      ;;
    jenkins)
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_set_header Host ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Real-IP ${REVERSE_PROXY_UP_HEADER};
          proxy_set_header X-Forwarded-For ${REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR};
          proxy_set_header X-Forwarded-Proto ${REVERSE_PROXY_PROTO_HEADER};
_EOF_
      ;;
    crucible)
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_set_header Host ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Real-IP ${REVERSE_PROXY_UP_HEADER};
          proxy_set_header X-Forwarded-for ${REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR};
_EOF_
      ;;
    *)
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_set_header X_FORWARDED_PROTO ${REVERSE_PROXY_PROTO_HEADER};
          proxy_set_header X-Forwarded-Host ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-Server ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-for ${REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR};
          proxy_set_header X-Forwarded-For ${REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR};
          proxy_set_header X-Real-IP ${REVERSE_PROXY_UP_HEADER};
          proxy_set_header Host ${REVERSE_PROXY_HOST_HEADER};
          port_in_redirect off;
_EOF_
  esac
}

for (( i = 1; ; i++ ))
do
  VAR_REVERSE_PROXY_LOCATION="$1REVERSE_PROXY_LOCATION$i"
  VAR_REVERSE_PROXY_PASS="$1REVERSE_PROXY_PASS$i"
  VAR_REVERSE_PROXY_BUFFERING="$1REVERSE_PROXY_BUFFERING$i"
  VAR_REVERSE_PROXY_BUFFERS="$1REVERSE_PROXY_BUFFERS$i"
  VAR_REVERSE_PROXY_BUFFERS_SIZE="$1REVERSE_PROXY_BUFFERS_SIZE$i"
  VAR_REVERSE_PROXY_HOST="$1SERVER_NAME"
  VAR_PROXY_CONTAINER_NETWORK_DNS="$1PROXY_CONTAINER_NETWORK_DNS"
  VAR_PROXY_APPLICATION="$1PROXY_APPLICATION"

  if [ ! -n "${!VAR_REVERSE_PROXY_LOCATION}" ]; then
    break
  fi

  configFileReverseProxy=${NGINX_DIRECTORY}/conf.d/server$2
  mkdir -p ${configFileReverseProxy}

  NGINX_PROXY_LOCATION=${!VAR_REVERSE_PROXY_LOCATION}
  NGINX_PROXY_PASS=${!VAR_REVERSE_PROXY_PASS}
  NGINX_PROXY_BUFFERING=${!VAR_REVERSE_PROXY_BUFFERING}
  NGINX_PROXY_BUFFERS=${!VAR_REVERSE_PROXY_BUFFERS}
  NGINX_PROXY_BUFFERS_SIZE=${!VAR_REVERSE_PROXY_BUFFERS_SIZE}
  NGINX_PROXY_HOST=${!VAR_REVERSE_PROXY_HOST}
  NGINX_PROXY_CONTAINER_NETWORK_DNS=${!VAR_PROXY_CONTAINER_NETWORK_DNS}
  NGINX_PROXY_APPLICATION=${!VAR_PROXY_APPLICATION}

  cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
        location ${NGINX_PROXY_LOCATION} {
_EOF_

  REVERSE_PROXY_BACKEND='$backend'
  REVERSE_PROXY_REDIRECT_PATTERN='$scheme://$host/'

  if [ -n "${NGINX_PROXY_PASS}" ]; then
    if  [ "${NGINX_PROXY_CONTAINER_NETWORK_DNS}" = "true" ]; then
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          resolver 127.0.0.1 valid=30s;
          set ${REVERSE_PROXY_BACKEND} "${NGINX_PROXY_PASS}";
          proxy_pass ${REVERSE_PROXY_BACKEND};
          proxy_redirect ${NGINX_PROXY_PASS} ${REVERSE_PROXY_REDIRECT_PATTERN};
_EOF_
    else
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_pass ${NGINX_PROXY_PASS};
          proxy_redirect ${NGINX_PROXY_PASS} ${REVERSE_PROXY_REDIRECT_PATTERN};
_EOF_
    fi

    setApplicationHeaders $NGINX_PROXY_APPLICATION
  fi

  if [ -n "${NGINX_PROXY_BUFFERING}" ]; then
    cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_buffering ${NGINX_PROXY_BUFFERING};
_EOF_
  fi

  if [ -n "${NGINX_PROXY_BUFFERS}" ]; then
    cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_buffers ${NGINX_PROXY_BUFFERS};
_EOF_
  fi

  if [ -n "${NGINX_PROXY_BUFFERS_SIZE}" ]; then
    cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_buffer_size ${NGINX_PROXY_BUFFERS_SIZE};
_EOF_
  fi

  cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
        }
_EOF_
  cat $configFileReverseProxy/reverseProxy.conf
done
