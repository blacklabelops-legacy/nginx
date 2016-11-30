# Dockerized Nginx

[![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/nginx.svg)](https://hub.docker.com/r/blacklabelops/nginx/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/nginx.svg)](https://hub.docker.com/r/blacklabelops/nginx/)

## Supported tags and respective Dockerfile links

| Version     | Tag          | Dockerfile |
|--------------|--------------|------------|
| latest | latest | [Dockerfile](https://github.com/blacklabelops/nginx/blob/master/Dockerfile) |
| 1.8.1-rc0 | 1.8.1-rc0 | [Dockerfile](https://github.com/blacklabelops/nginx/blob/master/Dockerfile) |

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
    -p 80:80 \
    --name nginx \
    blacklabelops/nginx
~~~~

> Default server installation will be available on port 80.

# Configuration File

You can use your own configuration file which will override the auto-configuration feature of this image.

Example:

~~~~
$ docker run -d \
    -v your_local_config_file.conf:/some/directory/nginx.conf \
    -e "NGINX_CONFIG_FILE=/some/directory/nginx.conf" \
    -p 80:80 \
    --name nginx \
    blacklabelops/nginx
~~~~

# Reverse Proxy Setup

~~~~
$ docker run -d \
    -p 80:80 \
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
    -p 80:80 \
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
    -p 80:80 \
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
    -p 80:80 \
    -p 443:443 \
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
    -p 80:80 \
    -p 443:443 \
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
    -p 443:443 \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1CERTIFICATE_DNAME=/CN=SBleul/OU=Blacklabelops/O=blacklabelops.com/L=Munich/C=DE" \
    -e "SERVER1HTTP_ENABLED=false" \
    --name nginx \
    blacklabelops/nginx
~~~~

> The reverse proxy will now only offer HTTPS communication!

# Set Http Header Fields

Applications, like Jira and Jenkins, usually need proxy header fields when you use nginx as a reverse proxy. You can set custom header fields when you use an application that is not directly supported by this image.

As an example Jira reqires the following proxy header fields:

1. `X-Forwarded-Host $host`
1. `X-Forwarded-Server $host`
1. `X-Forwarded-For $proxy_add_x_forwarded_for`

This image supports an arbitrary amount of header fields, the environment variables must enumerated, starting with index 1.

Syntax environment variable: `SERVER<server-number>REVERSE_PROXY_HEADER<proxy-number>FIELD<field-number>`

> Note: You must set `SERVER1PROXY_APPLICATION=custom` to `custom` otherwise the container will add default header fields by itself.

> Note: Inside docker and docker-compose the environment variable has to be quoted with `''` rather with `""`. This is also platform dependent, e.g. Mac and Linux. Please try and report how this behaves under Windows.

Example with 1 server and 1 reverse proxy:

~~~~
$ docker run -d \
    -p 80:80 \
    --name nginx \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e 'SERVER1PROXY_APPLICATION=custom' \
    -e "SERVER1REVERSE_PROXY_PASS1=http://jira.example.com" \
    -e 'SERVER1REVERSE_PROXY_HEADER1FIELD1=X-Forwarded-Host $host' \
    -e 'SERVER1REVERSE_PROXY_HEADER1FIELD2=X-Forwarded-Server $host' \
    -e 'SERVER1REVERSE_PROXY_HEADER1FIELD3=X-Forwarded-For $proxy_add_x_forwarded_for' \
    blacklabelops/nginx
~~~~

> Use `''` quotes otherwise variables like `$host` will be interpreted!

# Http2Https Redirection

Means that a call on the http adress will be redirected to https. Useful when users enter the http adress in browser and then will be redirected to the secured entry page.

Example:

1. Enter the URL `http://www.example.com`
1. Your browser will be redirected to `https://www.example.com`

This setting will be activated for all servers and all servers must deactivate http.

Example:

1. `NGINX_REDIRECT_PORT80=true` activates https port redirection for all servers.
1. `SERVER1HTTP_ENABLED=false` must be set for all servers.

Example:

~~~~
$ docker run -d \
    -p 443:443 \
    -p 80:80 \
    -e "NGINX_REDIRECT_PORT80=true" \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1SERVER_NAME=localhost" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1CERTIFICATE_DNAME=/CN=SBleul/OU=Blacklabelops/O=blacklabelops.com/L=Munich/C=DE" \
    -e "SERVER1HTTP_ENABLED=false" \
    --name nginx \
    blacklabelops/nginx
~~~~

> You can now access http://localhost and https://localhost and http will be redirected to https.

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
    -p 443:443 \
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

# Use Your Own Config File

Just mount or place your file at the position `/home/nginx/config.json`!

Example:

~~~~
$ docker run -d \
    -p 80:80 \
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
