Multi purpose Docker image with Nginx.

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](https://www.hipchat.com/geogBFvEM)

# Make It Short!

~~~~
$ docker run -d \
    -p 8080:8080 \
    --name nginx \
    blacklabelops/nginx
~~~~

> Default server installation will be available on port 8080.

# Reverse Proxy Setup

~~~~
$ docker run -d \
    -p 8080:8080 \
    --name nginx \
    -e "REVERSE_PROXY_LOCATION=/" \
    -e "REVERSE_PROXY_PASS=http://www.heise.de" \
    blacklabelops/nginx
~~~~

> Reverse proxy will pass to site http://www.heise.de.

# Multiple Reverse Proxies

It is possible to define an arbitrary amount of reverse proxies. Just add a number behind each environment variable.

Example:

Reverse Proxy 1:

* Location: /
* Proxy Pass: http://www.heise.de

Reverse Proxy 2:

* Location: /alternate
* Proxy Pass: http://www.alternate.de

~~~~
$ docker run -d \
    -p 8080:8080 \
    --name nginx \
    -e "REVERSE_PROXY_LOCATION1=/" \
    -e "REVERSE_PROXY_PASS1=http://www.heise.de" \
    -e "REVERSE_PROXY_LOCATION2=/alternate" \
    -e "REVERSE_PROXY_PASS2=http://www.alternate.de" \
    blacklabelops/nginx
~~~~

> Now try accessing http://localhost:8080 and https://localhost:8080/alternate (When using docker tools replace localhost with the respective ip)

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

> Reverse Proxy will be available on localhost:8080 on the host machine.

Vagrant does not leave any docker artifacts on your beloved desktop and the vagrant image can simply be destroyed and repulled if anything goes wrong. Test my project to your heart's content!

## References

* [NGINX](http://nginx.org/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
