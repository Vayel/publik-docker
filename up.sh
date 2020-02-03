#!/bin/bash

. ./init-env.sh

# If we don't create it ourselves a folder is created instead of a file
mkdir -p data
if [ ! -f ./data/hosts ]; then
  touch ./data/hosts
fi

docker-compose -f docker-compose.yml -f docker-compose.db.yml up --no-build --abort-on-container-exit
