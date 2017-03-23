#!/bin/bash

set -o errexit

function setApplicationHeaders() {
  local applicationId=$1
  local REVERSE_PROXY_HOST_HEADER='$host'
  local REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR='$proxy_add_x_forwarded_for'
  local REVERSE_PROXY_PROTO_HEADER='$scheme'
  local REVERSE_PROXY_UP_HEADER='$remote_addr'
  local REVERSE_PROXY_UPGRADE='$http_upgrade'
  local REVERSE_PROXY_CONNECTION_UPGRADE='"upgrade"'

  case "$applicationId" in
    confluence)
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_set_header X-Forwarded-Host ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-Server ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-For ${REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR};
_EOF_
      ;;
    confluence6)
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_set_header X-Forwarded-Host ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-Server ${REVERSE_PROXY_HOST_HEADER};
          proxy_set_header X-Forwarded-For ${REVERSE_PROXY_HOST_HEADER_FORWARDED_FOR};
          proxy_http_version 1.1;
          proxy_set_header Upgrade ${REVERSE_PROXY_UPGRADE};
          proxy_set_header Connection ${REVERSE_PROXY_CONNECTION_UPGRADE};
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
    custom)
      cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
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

function setProxyHeaderFields() {
  for (( q=1; ; q++ ))
  do
    VAR_PROXY_HEADER_FIELD="$1REVERSE_PROXY_HEADER$2FIELD$q"
    if [ ! -n "${!VAR_PROXY_HEADER_FIELD}" ]; then
      break
    fi
    NGINX_PROXY_HEADER_FIELD=${!VAR_PROXY_HEADER_FIELD}
    cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          proxy_set_header ${NGINX_PROXY_HEADER_FIELD};
_EOF_
  done
}

function setProxyDirectiveFields() {
  for (( d=1; ; d++ ))
  do
    VAR_PROXY_DIRECTIVE_FIELD="$1REVERSE_PROXY_DIRECTIVE$2FIELD$d"
    if [ ! -n "${!VAR_PROXY_DIRECTIVE_FIELD}" ]; then
      break
    fi
    NGINX_PROXY_DIRECTIVE_FIELD=${!VAR_PROXY_DIRECTIVE_FIELD}
    cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          ${NGINX_PROXY_DIRECTIVE_FIELD};
_EOF_
  done
}

function createBasicAuthFile() {
  local reverse_proxy_basic_auth_id=$1
  local passwd_file=$2
  for (( u=1; ; u++ ))
  do
    local VAR_BASIC_AUTH_USER="${reverse_proxy_basic_auth_id}USER${u}"
    local VAR_BASIC_AUTH_PASSWORD="${reverse_proxy_basic_auth_id}PASSWORD${u}"
    if [ ! -n "${!VAR_BASIC_AUTH_USER}" ]; then
      break
    fi
    local BASIC_AUTH_USER="${!VAR_BASIC_AUTH_USER}"
    local BASIC_AUTH_PASSWORD="${!VAR_BASIC_AUTH_PASSWORD}"
    htpasswd -b $passwd_file $BASIC_AUTH_USER $BASIC_AUTH_PASSWORD
  done
}

for (( i=1; ; i++ ))
do
  VAR_REVERSE_PROXY_LOCATION="$1REVERSE_PROXY_LOCATION$i"
  VAR_REVERSE_PROXY_PASS="$1REVERSE_PROXY_PASS$i"
  VAR_REVERSE_PROXY_BUFFERING="$1REVERSE_PROXY_BUFFERING$i"
  VAR_REVERSE_PROXY_BUFFERS="$1REVERSE_PROXY_BUFFERS$i"
  VAR_REVERSE_PROXY_BUFFERS_SIZE="$1REVERSE_PROXY_BUFFERS_SIZE$i"
  VAR_REVERSE_PROXY_HOST="$1SERVER_NAME"
  VAR_PROXY_APPLICATION="$1PROXY_APPLICATION"
  VAR_PROXY_APPLICATION_PROXY="$1REVERSE_PROXY_APPLICATION$i"
  VAR_REVERSE_PROXY_BASIC_AUTH_REALM="$1REVERSE_PROXY_BASIC_AUTH_REALM$i"

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
  NGINX_PROXY_APPLICATION=${!VAR_PROXY_APPLICATION}
  NGINX_PROXY_APPLICATION_PROXY=${!VAR_PROXY_APPLICATION_PROXY}
  NGINX_PROXY_BASIC_AUTH_REALM=${!VAR_REVERSE_PROXY_BASIC_AUTH_REALM}

  if [ -n "${NGINX_PROXY_APPLICATION_PROXY}" ]; then
    NGINX_PROXY_APPLICATION=${NGINX_PROXY_APPLICATION_PROXY}
  fi

  cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
        location ${NGINX_PROXY_LOCATION} {
_EOF_

  REVERSE_PROXY_BACKEND_VARIABLE='$backend'
  REVERSE_PROXY_BACKEND='$backend$uri$is_args$args'

  if [ -n "${NGINX_PROXY_PASS}" ]; then
    cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          set ${REVERSE_PROXY_BACKEND_VARIABLE} "${NGINX_PROXY_PASS}";
          proxy_pass ${REVERSE_PROXY_BACKEND};
_EOF_
    setApplicationHeaders $NGINX_PROXY_APPLICATION

    setProxyHeaderFields $1 $i

    setProxyDirectiveFields $1 $i
  fi

  if [ -n "${NGINX_PROXY_BASIC_AUTH_REALM}" ]; then
    htpasswd_file=$configFileReverseProxy/htpasswd_reverse_proxy$i
    touch $htpasswd_file
    cat >> $configFileReverseProxy/reverseProxy.conf <<_EOF_
          auth_basic "${NGINX_PROXY_BASIC_AUTH_REALM}";
          auth_basic_user_file ${htpasswd_file};
_EOF_
    createBasicAuthFile "$1REVERSE_PROXY_BASIC_AUTH${i}" $htpasswd_file
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
