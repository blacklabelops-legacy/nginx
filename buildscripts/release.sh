#!/bin/bash -x

#------------------
# CONTAINER VARIABLES
#------------------
export NGINX_VERSION=1.10.1-r1
git branch
export BUILD_BRANCH=$(git branch | grep -e "^*" | cut -d' ' -f 2)
