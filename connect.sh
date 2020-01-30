#!/bin/sh

container=$1

if [ -z "$1" ]
then
  container=components
fi

docker exec -it "$container" /bin/bash
