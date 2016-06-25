#!/bin/bash -x

#------------------
# CONTAINER VARIABLES
#------------------
export NGINX_VERSION=1.10.1-r1
export BUILD_BRANCH=$(git branch | grep -e "^*" | awk '/^\*/{print $2}')
