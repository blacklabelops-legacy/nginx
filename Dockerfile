FROM blacklabelops/alpine
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
      openssl && \
    if  [ "${NGINX_VERSION}" = "latest" ]; \
      then apk add nginx ; \
      else apk add "nginx=${NGINX_VERSION}" ; \
    fi && \
    mkdir -p /var/log/nginx && \
    mkdir -p ${NGINX_DIRECTORY}/default.d && \
    mkdir -p ${NGINX_DIRECTORY}/conf.d && \
    mkdir -p ${NGINX_DIRECTORY}/keys && \
    chown -R $CONTAINER_UID:$CONTAINER_GID ${NGINX_DIRECTORY} /var/log/nginx && \
    chown -R $CONTAINER_UID:$CONTAINER_GID ${NGINX_DIRECTORY} /var/lib/nginx && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/*

EXPOSE 8080
EXPOSE 44300

USER $CONTAINER_USER
COPY imagescripts/*.sh /opt/nginx-scripts/
ENTRYPOINT ["/opt/nginx-scripts/docker-entrypoint.sh"]
VOLUME ["/home/nginx","/var/lib/nginx/","/var/log/nginx"]
CMD ["nginx"]
