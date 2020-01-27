#!/bin/bash

set -eu

. ./load-env.sh

# If we don't create it ourselves a folder is created instead of a file
mkdir -p data
if [ ! -f ./data/hosts ]; then
  touch ./data/hosts
fi

docker-compose -p "$COMPOSE_PROJECT_NAME" -f docker-compose.certificates.yml up

zip -r data.zip data

echo "******************************"
echo "SUCCESS: certificates built"
echo "Download data.zip and unzip it"
echo "******************************"
