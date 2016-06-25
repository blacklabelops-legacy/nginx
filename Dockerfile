FROM blacklabelops/alpine:3.4
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

# Build time arguments
#Values: latest or version number (e.g. 1.8.1-r0)
ARG NGINX_VERSION=latest
#Permissions, set the linux user id and group id
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000

# install dev tools
ENV NGINX_DIRECTORY=/opt/nginx

RUN export CONTAINER_USER=nginx && \
    export CONTAINER_GROUP=nginx && \
    # Add user
    addgroup -g $CONTAINER_GID $CONTAINER_GROUP && \
    adduser -u $CONTAINER_UID -G $CONTAINER_GROUP -h /home/$CONTAINER_USER -s /bin/bash -S $CONTAINER_USER && \
    apk add --update \
      ca-certificates \
      curl \
      openssl && \
    if  [ "${NGINX_VERSION}" = "latest" ]; \
      then apk add nginx ; \
      else apk add "nginx=${NGINX_VERSION}" ; \
    fi && \
    mkdir -p /var/log/nginx && \
    touch /var/log/nginx/error.log && \
    mkdir -p ${NGINX_DIRECTORY}/default.d && \
    mkdir -p ${NGINX_DIRECTORY}/conf.d && \
    mkdir -p ${NGINX_DIRECTORY}/keys && \
    mkdir -p /var/run/nginx && \
    chown -R $CONTAINER_UID:$CONTAINER_GID ${NGINX_DIRECTORY} /var/log/nginx && \
    chown -R $CONTAINER_UID:$CONTAINER_GID ${NGINX_DIRECTORY} /var/lib/nginx && \
    chown -R $CONTAINER_UID:$CONTAINER_GID ${NGINX_DIRECTORY} /var/run/nginx && \
    # Install Tini Zombie Reaper And Signal Forwarder
    export TINI_VERSION=0.9.0 && \
    export TINI_SHA=fa23d1e20732501c3bb8eeeca423c89ac80ed452 && \
    curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static -o /bin/tini && \
    echo 'Calculated checksum: '$(sha1sum /bin/tini) && \
    chmod +x /bin/tini && echo "$TINI_SHA  /bin/tini" | sha1sum -c - && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/*

EXPOSE 80 443

USER root
COPY imagescripts/*.sh /opt/nginx/
ENTRYPOINT ["/bin/tini","--","/opt/nginx/docker-entrypoint.sh"]
VOLUME ["/home/nginx"]
CMD ["nginx"]
