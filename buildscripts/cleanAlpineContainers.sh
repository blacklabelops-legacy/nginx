#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly TEST_NGINX_VERSION=$NGINX_VERSION

function cleanContainer() {
  local container=$1
  docker rm -f -v $container || true
}

cleanContainer latest
cleanContainer $TEST_JENKINS_VERSION
