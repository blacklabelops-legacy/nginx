Multi purpose Docker image with Nginx.

Major rewrite: The naming of the environment variables have been changed in order to support multiple servers and proxies. If you are using the old naming of environment variables then switch to the old version of this image on docherhub:

~~~~
blacklabelops/nginx:0.0.1
~~~~

Features:

* Supports configuration of multiple servers with environment variables.
* Supports an arbitrary amount of reverse proxies for every server.
* Supports https and ad-hoc self-signed certificates
* Supports ssl certificate specification for every server.
* Supports letsencryt certificates.

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](https://www.hipchat.com/geogBFvEM)

# Make It Short!

~~~~
$ docker run -d \
    -p 80:8080 \
    --name nginx \
    blacklabelops/nginx
~~~~

> Default server installation will be available on port 80.

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

First start a data container where the certificate will be stored.

~~~~
$ docker run -d \
    -v /etc/letsencrypt \
    --name letsencrypt_data \
    blacklabelops/centos bash -c "chown -R 1000:1000 /etc/letsencrypt"
~~~~

> Letsencrypt stores the certificates inside the folder /etc/letsencrypt.

Then start the letsencrypt container interactively and create the certificates manually.

~~~~
$ docker run -it --rm -p 443:443 -p 80:80 --name letsencrypt \
    --volumes-from letsencrypt_data \
    quay.io/letsencrypt/letsencrypt:latest auth
~~~~

> This container will handshake with letsencrypt.org and generate the certificates when successful.

Before we can use them you will have to set the appropriate permissions for the nginx user!

~~~~
$ docker start letsencrypt_data
~~~~

> The data container will repeat the instruction: chown -R 1000:1000 /etc/letsencrypt

Now you can use the certificate for your reverse proxy!

~~~~
$ docker run -d \
    -p 443:44300 \
    --volumes-from letsencrypt_data \
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
