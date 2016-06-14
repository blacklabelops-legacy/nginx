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
  docker run -d -p 80:80 --name=$tagname blacklabelops/nginx:$tagname
  while ! curl -v http://localhost
  do
      { echo "Exit status of curl: $?"
        echo "Retrying ..."
      } 1>&2
      if [ "$iteration" = '30' ]; then
        exit 1
      else
        ((iteration=iteration+1))
      fi
      sleep 10
  done
  docker rm -f $tagname
}

testPrintVersion $1
testImage $1 $2
