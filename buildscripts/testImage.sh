#!/bin/bash -x

set -o errexit    # abort script at first error

function testPrintVersion() {
  local tagname=$1
  docker run --rm blacklabelops/nginx:$tagname -v
}

function testImage() {
  local tagname=$1
  local port=$2
  local iteration=0

  docker run -d -p $port:80 --name=$tagname blacklabelops/nginx:$tagname
  docker exec $tagname nginx -v
  docker logs $tagname
  docker rm -f $tagname
}

testPrintVersion $1
testImage $1 $2
