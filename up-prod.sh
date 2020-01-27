#!/bin/bash

. ./load-env.sh

# If we don't create it ourselves a folder is created instead of a file
mkdir -p data
if [ ! -f ./data/hosts ]; then
  touch ./data/hosts
fi

docker-compose -f docker-compose.yml -f docker-compose.prod.yml -p "$COMPOSE_PROJECT_NAME" -f up --no-build --abort-on-container-exit
