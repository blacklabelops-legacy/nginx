#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly TEST_NGINX_VERSION=$NGINX_VERSION

source $CUR_DIR/testImage.sh latest 8430
source $CUR_DIR/testImage.sh $TEST_NGINX_VERSION 8440
