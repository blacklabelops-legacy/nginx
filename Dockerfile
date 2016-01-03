FROM blacklabelops/centos
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

# Propert permissions
ENV CONTAINER_USER nginx
ENV CONTAINER_UID 1000
ENV CONTAINER_GROUP nginx
ENV CONTAINER_GID 1000

RUN /usr/sbin/groupadd --gid $CONTAINER_GID nginx && \
    /usr/sbin/useradd --uid $CONTAINER_UID --gid $CONTAINER_GID --create-home --shell /bin/bash nginx

# install dev tools
ENV NGINX_DIRECTORY=/opt/nginx
RUN yum install -y epel-release && \
    yum install -y ca-certificates nginx openssl && \
    yum clean all && rm -rf /var/cache/yum/* && \
    mkdir -p /var/log/nginx && \
    mkdir -p ${NGINX_DIRECTORY}/default.d && \
    mkdir -p ${NGINX_DIRECTORY}/conf.d && \
    mkdir -p ${NGINX_DIRECTORY}/keys && \
    touch /var/log/nginx/access.log && \
    touch /var/log/nginx/error.log && \
    chown -R $CONTAINER_UID:$CONTAINER_GID ${NGINX_DIRECTORY} /var/log/nginx

EXPOSE 8080
EXPOSE 44300

USER $CONTAINER_USER
COPY imagescripts/*.sh /opt/nginx-scripts/
ENTRYPOINT ["/opt/nginx-scripts/docker-entrypoint.sh"]
CMD ["nginx"]
