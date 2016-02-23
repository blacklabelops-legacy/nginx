# Dockerized Nginx

[![Circle CI](https://circleci.com/gh/blacklabelops/jenkins/tree/master.svg?style=shield)](https://circleci.com/gh/blacklabelops/jenkins/tree/master) [![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/jenkins.svg)](https://hub.docker.com/r/blacklabelops/jenkins/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/jenkins.svg)](https://hub.docker.com/r/blacklabelops/jenkins/)

## Supported tags and respective Dockerfile links

| Version     | Tag          | Dockerfile |
|--------------|--------------|------------|
| latest | latest | [Dockerfile](https://github.com/blacklabelops/nginx/blob/master/Dockerfile) |
| 1.8.1-rc0 | 1.8.1 | [Dockerfile](https://github.com/blacklabelops/nginx/blob/master/Dockerfile) |

# Features

* Supports configuration of multiple servers with environment variables.
* Supports an arbitrary amount of reverse proxies for every server.
* Supports https and ad-hoc self-signed certificates
* Supports ssl certificate specification for every server.
* Supports letsencryt certificates.

# Support & Feature Requests

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](https://www.hipchat.com/geogBFvEM)

# Make It Short!

~~~~
$ docker run -d \
    -p 80:8080 \
    --name nginx \
    blacklabelops/nginx
~~~~

> Default server installation will be available on port 80.

# Configuration File

You can use your own configuration file which will override the auto-configuration feature of this image. Just mount your place your config file at the following location: `/home/nginx/nginx.conf`

Example:

~~~~
$ docker run -d \
    -v your_local_config_file.conf:/home/nginx/nginx.conf \
    -p 80:8080 \
    --name nginx \
    blacklabelops/nginx
~~~~

# Reverse Proxy Setup

~~~~
$ docker run -d \
    -p 80:8080 \
    --name nginx \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    blacklabelops/nginx
~~~~

> Reverse proxy will pass to site http://www.heise.de.

# Multiple servers

It is possible to define an arbitrary amount of server definitions with environment variables. Each variable must be precede by the string "SERVER" and the number of the server.

Example:

Server 1 Reverse Proxy 1:

* Location: /
* Proxy Pass: http://www.heise.de

Server 2 Reverse Proxy 1:

* Server name: dummy.example.com
* Location: /
* Proxy Pass: http://www.alternate.de

~~~~
$ docker run -d \
    -p 80:8080 \
    --name nginx \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER2SERVER_NAME=dummy.example.com"
    -e "SERVER2REVERSE_PROXY_LOCATION2=/alternate" \
    -e "SERVER2REVERSE_PROXY_PASS2=http://www.alternate.de" \
    blacklabelops/nginx
~~~~

> Now try accessing http://localhost (When using docker tools replace localhost with the respective ip) in order to invoke the second proxy you will have to use a dns server for requests originating from dummy.example.com

# Multiple Reverse Proxies

It is possible to define an arbitrary amount of reverse proxies for every server. Just precede each environment variable with the String "SERVER" and the number of the server and add a number behind each environment variable.

Example:

Reverse Proxy 1:

* Location: /
* Proxy Pass: http://www.heise.de

Reverse Proxy 2:

* Location: /alternate
* Proxy Pass: http://www.alternate.de

~~~~
$ docker run -d \
    -p 80:8080 \
    --name nginx \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1REVERSE_PROXY_LOCATION2=/alternate" \
    -e "SERVER1REVERSE_PROXY_PASS2=http://www.alternate.de" \
    blacklabelops/nginx
~~~~

> Now try accessing http://localhost and https://localhost/alternate (When using docker tools replace localhost with the respective ip)

# HTTPS Reverse Proxy

This container supports HTTPS. Just enter a DName with the environment variable CERTIFICATE_DNAME and the container creates a self-signed certificate. You have to pass Distinguished Name (DN). The certificate is generated with the Distinguished Name. This is a DN-Example:

~~~~
/CN=SBleul/OU=Blacklabelops/O=blacklabelops.net/L=Munich/C=DE
~~~~

  * CN = Your name
  * OU = Your organizational unit.
  * O = Organisation name.
  * L = Location, e.g. town name.
  * C = Locale of your county.

~~~~
$ docker run -d \
    -p 80:8080 \
    -p 443:44300 \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1CERTIFICATE_DNAME=/CN=SBleul/OU=Blacklabelops/O=blacklabelops.com/L=Munich/C=DE" \
    -e "SERVER1HTTPS_ENABLED=true" \
    --name nginx \
    blacklabelops/nginx
~~~~

> Note: Webserver will use same port for HTTPS!

# Custom HTTPS Certificates

Using your own certificates: Mount them inside the
container define their location with the environment-variables CERTIFICATE_FILE and CERTIFICATE_KEY.

~~~~
$ docker run -d \
    -p 80:8080 \
    -p 443:44300 \
    -v /mycertificatepath/mycertificates:/opt/nginx/keys \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1CERTIFICATE_FILE=/opt/nginx/keys/server.csr" \
    -e "SERVER1CERTIFICATE_KEY=/opt/nginx/keys/server.key" \
    --name nginx \
    blacklabelops/nginx
~~~~

# Disable HTTP

HTTP should be disabled when using HTTPS. Just disable the port and disable HTTP inside the config using the environment-variable HTTP_ENABLED.

Example:

~~~~
$ docker run -d \
    -p 44300:44300 \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1CERTIFICATE_DNAME=/CN=SBleul/OU=Blacklabelops/O=blacklabelops.com/L=Munich/C=DE" \
    -e "SERVER1HTTP_ENABLED=false" \
    --name nginx \
    blacklabelops/nginx
~~~~

> The reverse proxy will now only offer HTTPS communication!

# Generating Green HTTPS Certificates with Letsencrypt

You can get and use free green certificates by [Letsencrypt](https://letsencrypt.org/). Here I will provide a manual way to generate and retrieve the certificate manually and use it inside the container. The full detailed letsencrypt documentation can be found here: [Documentation](https://community.letsencrypt.org/c/docs/)

Note: This will not work inside boot2docker on your local comp. You will have to do this inside your target environment.

First create a data volume where the certificate will be stored.

~~~~
$ docker volume create --name letsencrypt_certs
~~~~

> Needs at least Docker 1.10 volumes.

Then start the letsencrypt container and create the certificate.

~~~~
$ docker run --rm \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    -v letsencrypt_certs:/etc/letsencrypt \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=example.com" \
    blacklabelops/letsencrypt install
~~~~

> This container will handshake with letsencrypt.org and install an account and the certificate when successful. Letsencrypt stores the certificates inside the folder /etc/letsencrypt.

Now you can use the certificate for your reverse proxy!

~~~~
$ docker run -d \
    -p 443:44300 \
    -v letsencrypt_certs:/etc/letsencrypt \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=false" \
    -e "SERVER1LETSENCRYPT_CERTIFICATES=true" \
    -e "SERVER1CERTIFICATE_FILE=/etc/letsencrypt/live/example.com/fullchain.pem" \
    -e "SERVER1CERTIFICATE_KEY=/etc/letsencrypt/live/example.com/privkey.pem" \
    -e "SERVER1CERTIFICATE_TRUSTED=/etc/letsencrypt/live/example.com/fullchain.pem" \
    --name nginx \
    blacklabelops/nginx
~~~~

> LETSENCRYPT_CERTIFICATES switches on special configuration for their certificates.

# Build The Image

The build process can take the following argument:

* NGINX_VERSION: Takes keyword `latest` or specific NGINX version number. Default is `latest`.

Examples:

Build image with the latest Jenkins release:

~~~~
$ docker build -t blacklabelops/nginx .
~~~~

> Note: Dockerfile must be inside the current directory!

Build image with a specific NGINX release:

~~~~
$ docker build --build-arg NGINX_VERSION=1.8.1-r0  -t blacklabelops/nginx .
~~~~

> Note: Dockerfile must be inside the current directory!

# Using Docker Compose

The build configuration are specified inside the following area:

~~~~
jenkins:
  build:
    context: .
    dockerfile: Dockerfile
    args:
      NGINX_VERSION: latest
~~~~

> Adjust NGINX_VERSION for your personal needs.

Build the latest release with docker-compose:

~~~~
$ docker-compose build
~~~~

# Container Permissions

Simply: You can set user-id and group-id matching to a user and group from your host machine!

Due to security considerations this image is not running in root mode! The Jenkins process user inside the container is `nginx` and the user's group is `nginx`. This project offers a simplified mechanism for user- and group-mapping. You can set the uid of the user and gid of the user's group during build time.

The process permissions are relevant when using volumes and mounted folders from the host machine. NGINX need read and write permissions on the host machine. You can set UID and GID of the NGINX's process during build time! UID and GID should resemble credentials from your host machine.

The following build arguments can be used:

* CONTAINER_UID: Set the user-id of the process. (default: 1000)
* CONTAINER_GID: Set the group-id of the process. (default: 1000)

Example:

~~~~
$ docker build --build-arg CONTAINER_UID=2000 --build-arg CONTAINER_GID=2000 -t blacklabelops/nginx .
~~~~

> The container will write and read files with UID 2000 and GID 2000.

# Use Your Own Config File

Just mount or place your file at the position `/home/nginx/config.json`!

Example:

~~~~
$ docker run -d \
    -p 80:8080 \
    --name nginx \
    -v config.json:/home/nginx/config.json \
    blacklabelops/nginx
~~~~

> File config.json is your local configuration file.

# How To Extend This Image

Minimal working example Dockerfile:

~~~~
FROM blacklabelops/nginx
MAINTAINER Your Name <your@email.com>

USER root
RUN echo "Install Your Tools"

USER nginx
# Optional: Your config file
COPY config.json /home/nginx/config.json
# Optional: Your entrypoint:
COPY entrypoint.sh /opt/nginx-scripts/
ENTRYPOINT ["/opt/nginx-scripts/entrypoint.sh"]
CMD ["nginx"]
~~~~

Minimal working example entrypoint `entrypoint.sh`:

~~~~
#!/bin/bash -x

# Your code
echo My script code

# Then call image entrypoint
exec /opt/nginx-scripts/docker-entrypoint.sh
~~~~

# Vagrant

Vagrant is fabulous tool for pulling and spinning up virtual machines like docker with containers. I can configure my development and test environment and simply pull it online. And so can you! Install Vagrant and Virtualbox and spin it up. Change into the project folder and build the project on the spot!

First install:

* [Vagrant](https://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)

~~~~
$ vagrant up
$ vagrant ssh
[vagrant@localhost ~]$ cd /vagrant
[vagrant@localhost ~]$ docker-compose up
~~~~

> Reverse Proxy will be available on localhost:80 on the host machine.

Vagrant does not leave any docker artifacts on your beloved desktop and the vagrant image can simply be destroyed and repulled if anything goes wrong. Test my project to your heart's content!

## References

* [NGINX](http://nginx.org/)
* [Letsencrypt](https://letsencrypt.org/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
