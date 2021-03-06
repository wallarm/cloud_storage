#!/bin/sh

set -e

for line in $(docker images -f "label=com.cloud_storage.ruby.version" -q | uniq); do
  ver=$(docker inspect --format '{{ index .Config.Labels "com.cloud_storage.ruby.version"}}' $line)

  if ! [ $ver = $DOCKER_RUBY_VERSION ]; then
    docker image rm --force $line
  fi
done
