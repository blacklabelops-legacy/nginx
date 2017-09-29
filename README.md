# Dockerized Nginx

[![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/nginx.svg)](https://hub.docker.com/r/blacklabelops/nginx/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/nginx.svg)](https://hub.docker.com/r/blacklabelops/nginx/)

# Supported Tags And Respective Dockerfiles

| Nginx Version     | Tag          | Dockerfile |
|-------------------|--------------|------------|
| latest | latest | [Dockerfile](https://github.com/blacklabelops/nginx/blob/master/Dockerfile) |
| 1.10.3-r0 | 2.2 | [Dockerfile](https://github.com/blacklabelops/nginx/blob/2.2/Dockerfile) |
| undefined | development | [Dockerfile](https://github.com/blacklabelops/nginx/blob/development/Dockerfile) |

> Recommended: Use tagged versioned image. Read the release notes. Always jump from one version to the next, rollback when necessary.

# Features

* Supports configuration of multiple servers with environment variables.
* Supports an arbitrary amount of reverse proxies for every server.
* Supports https and ad-hoc self-signed certificates
* Supports ssl certificate specification for every server.
* Supports letsencrypt certificates.

# Support & Feature Requests

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](http://support.blacklabelops.com)

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
    -v your_local_config_file.conf:/etc/nginx/nginx.conf \
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
    -e "SERVER2SERVER_NAME=dummy.example.com" \
    -e "SERVER2REVERSE_PROXY_LOCATION1=/alternate" \
    -e "SERVER2REVERSE_PROXY_PASS1=http://www.alternate.de" \
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

You can also provide custom Nginx directives using a similar pattern: `SERVER<server-number>REVERSE_PROXY_DIRECTIVE<proxy-number>FIELD<field-number>`

> Note: You must set `SERVER1PROXY_APPLICATION=custom` to `custom` otherwise the container will add default header fields by itself.

> Note: Inside docker and docker-compose the environment variable has to be quoted with `''` rather with `""`. Alternatively a `$` symbol can be substituted with `$$` when not using single quotes. This is also platform dependent, e.g. Mac and Linux. Please try and report how this behaves under Windows.

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
    -e 'SERVER1REVERSE_PROXY_DIRECTIVE1FIELD1=proxy_read_timeout 300' \
    blacklabelops/nginx
~~~~

> Use `''`, `$$`, or quotes otherwise variables like `$host` will be interpreted!

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
    -p 80:80 \
    -v letsencrypt_certs:/etc/letsencrypt \
    -e "NGINX_REDIRECT_PORT80=true" \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=false" \
    -e "SERVER1LETSENCRYPT_CERTIFICATES=true" \
    -e "SERVER1CERTIFICATE_FILE=/etc/letsencrypt/live/example.com/cert.pem" \
    -e "SERVER1CERTIFICATE_KEY=/etc/letsencrypt/live/example.com/privkey.pem" \
    -e "SERVER1CERTIFICATE_TRUSTED=/etc/letsencrypt/live/example.com/fullchain.pem" \
    --name nginx \
    blacklabelops/nginx
~~~~

> LETSENCRYPT_CERTIFICATES switches on special configuration for their certificates.

# Automated Letsencrypt Certificate renewal

This image supports automatic monthly letsencrypt certificate renewal with side-containers. Ports 80 and 443 are used by Nginx, therefore we use webroot challenging for certificate renewal.

After each renewal Nginx configuration and certificates are loaded without restarting Nginx itself and disturb the availability of the system.

1. Create a challenge volume between your Letsencrypt and Nginx containers.
1. Start Nginx container with the challenge volume.
1. Start Letsencrypt container with challenge volume and webroot mode.
1. Finally start a Cron container in order to reload your Nginx configuration after certificates changed.

Create additional volume for acme handshakes:

~~~~
$ docker volume create letsencrypt_challenges
~~~~

> This is where acme challenges from letsencrypt are stored and handled by Nginx.

Then start Nginx with your SSL settings and the challenge volume:

~~~~
$ docker run -d \
    -p 443:443 \
    -p 80:80 \
    -v letsencrypt_certs:/etc/letsencrypt \
    -v letsencrypt_challenges:/var/www/letsencrypt \
    -e "NGINX_REDIRECT_PORT80=true" \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=false" \
    -e "SERVER1LETSENCRYPT_CERTIFICATES=true" \
    -e "SERVER1CERTIFICATE_FILE=/etc/letsencrypt/live/example.com/cert.pem" \
    -e "SERVER1CERTIFICATE_KEY=/etc/letsencrypt/live/example.com/privkey.pem" \
    -e "SERVER1CERTIFICATE_TRUSTED=/etc/letsencrypt/live/example.com/fullchain.pem" \
    --name nginx \
    blacklabelops/nginx
~~~~

> Nginx can now handle acme challenge tokens over the volume.

Now start letsencrypt in renewal mode, this will renew certificates each month!

~~~~
$ docker run -d \
    -v letsencrypt_certs:/etc/letsencrypt \
    -v letsencrypt_challenges:/var/www/letsencrypt \
    -e "LETSENCRYPT_WEBROOT_MODE=true" \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=example.com" \
    --name letsencrypt \
    blacklabelops/letsencrypt
~~~~

> This container will handshake with letsencrypt.org each month on the 15th and renewal the certificate when successful.

Finally start a cron container that will reload the Nginx configuration after the certificates have been renewed!

~~~~
$ docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "JOB_NAME1=ReloadNginx" \
    -e "JOB_COMMAND1=docker exec nginx nginx -s reload" \
    -e "JOB_TIME1=0 0 2 15 * *" \
    -e "JOB_ON_ERROR1=Continue" \
    blacklabelops/jobber:docker
~~~~

> Reloads Nginx configuration each month on the 15th over Docker without restarting Nginx! In order to achieve high availability!

# Basic User Authentication

You can password protect any reverse proxy. Additionally you can specify an arbitrary amount of users.

Example of specifying a user `admin` with password `admin` for the first reverse proxy:

~~~~
docker run -d \
    -p 80:80 \
    --name nginx \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1REVERSE_PROXY_BASIC_AUTH_REALM1=Secure Location" \
    -e "SERVER1REVERSE_PROXY_BASIC_AUTH1USER1=admin" \
    -e "SERVER1REVERSE_PROXY_BASIC_AUTH1PASSWORD1=admin" \
    blacklabelops/nginx
~~~~

> Access to http://localhost will be now password protected with user `admin` and password `admin`.

Multiple users:

~~~~
docker run -d \
    -p 80:80 \
    --name nginx \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "SERVER1REVERSE_PROXY_BASIC_AUTH_REALM1=Secure Location" \
    -e "SERVER1REVERSE_PROXY_BASIC_AUTH1USER1=admin1" \
    -e "SERVER1REVERSE_PROXY_BASIC_AUTH1PASSWORD1=admin1" \
    -e "SERVER1REVERSE_PROXY_BASIC_AUTH1USER2=admin2" \
    -e "SERVER1REVERSE_PROXY_BASIC_AUTH1PASSWORD2=admin2" \
    blacklabelops/nginx
~~~~

> Access to http://localhost are both enabled for user `admin1` and user `admin2`.

# Changing Log Level and disabling the Access Log

If you find the access log output too verbose, it can be disabled.

~~~~
$ docker run -d \
    -p 80:80 \
    --name nginx \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "LOG_LEVEL=warn" \
    -e "DISABLE_ACCESS_LOG=true" \
    blacklabelops/nginx
~~~~

# Use IPv6

You can use IPv6 instead of IPv4 (default).

~~~~
$ docker run -d \
    -p 80:80 \
    --name nginx \
    -e "NGINX_USE_IPV6"="true"
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://www.heise.de" \
    blacklabelops/nginx
~~~~

# Use custom HTTP or HTTPS ports

If you want to pass requests to the Docker host, you need to connect the NGINX container directly to the host networking stack.

Unfortunately, if your Docker host is running on a QNAP NAS, port 80 and 443 (as well as 8080 and 8081) are already used by the embedded web server. You can use custom ports in such a case.

~~~~
$ docker run -d \
    --net=host \
    --name nginx \
    -e "NGINX_HTTP_PORT"="9000" \
    -e "NGINX_HTTPS_PORT"="9001" \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://localhost:8080" \
    blacklabelops/nginx
~~~~

> Note: If you use port forwarding on your router, you need to forward port 80 and 443 to port 9000 and 9001.

# Serving static files

When using frameworks such as Django behind a reverse proxy, best practice is to use nginx to serve static files such as css or js files.

To support this use a Docker volume to map the static files into the nginx container and a custom Proxy Directive to make it available at a location:

~~~~
$ docker run -d \
    --name app \
    --network app_network \
    -v app_volume:<path to static files> \
    my/app

$ docker run -d \
    -p 80:80 \
    --name nginx \
    --network app_network \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://app:8080" \
    -e "SERVER1REVERSE_PROXY_LOCATION2=/static/" \
    -e "SERVER1REVERSE_PROXY_APPLICATION2=custom" \
    -e "SERVER1REVERSE_PROXY_DIRECTIVE2FIELD1: 'alias /var/lib/nginx/html/static/' \
    -v app_volume:/var/lib/nginx/html/static \
    blacklabelops/nginx
~~~~

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

# How To Extend This Image

Minimal working example:

~~~~
FROM blacklabelops/nginx

RUN echo "Install Your Tools"

# Optional: Your config file
COPY nginx.conf /etc/nginx/nginx.conf
~~~~

Example with custom entrypoint:

~~~~
FROM blacklabelops/nginx

USER root
RUN echo "Install Your Tools"

# Optional: Your config file
COPY nginx.conf /etc/nginx/nginx.conf
# Optional: Your entrypoint:
COPY entrypoint.sh /opt/nginx/
ENTRYPOINT ["/opt/nginx/entrypoint.sh"]
~~~~

Minimal working example entrypoint `entrypoint.sh`:

~~~~
#!/bin/bash

# Your code
echo "My script code"

# Then call image entrypoint
exec /opt/nginx/docker-entrypoint.sh
~~~~

## References

* [NGINX](http://nginx.org/)
* [Letsencrypt](https://letsencrypt.org/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
