#!/bin/bash -x

set -o errexit    # abort script at first error

function testPrintVersion() {
  local tagname=$1
  local branch=$(git symbolic-ref --short HEAD)
  if  [ "${branch}" = "master" ]; then
    imagename=$tagname
  else
    imagename=$tagname-$branch
  fi
  docker run --rm blacklabelops/nginx:$imagename -v
}

function testImage() {
  local tagname=$1
  local port=$2
  local iteration=0
  local branch=$(git symbolic-ref --short HEAD)
  if  [ "${branch}" = "master" ]; then
    imagename=$tagname
  else
    imagename=$tagname-$branch
  fi
  docker run -d --name=$imagename blacklabelops/nginx:$imagename
  while ! docker run --rm --link $imagename:nginx blacklabelops/nginx:$imagename curl -v http://nginx
  do
      { echo "Exit status of curl: $?"
        echo "Retrying ..."
      } 1>&2
      if [ "$iteration" = '30' ]; then
        docker logs $imagename
        exit 1
      else
        ((iteration=iteration+1))
      fi
      sleep 10
  done
  docker rm -f -v $imagename
}

testPrintVersion $1
testImage $1 $2
