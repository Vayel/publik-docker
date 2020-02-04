#!/bin/bash

set -eu

. ./init-env.sh

# If we don't create it ourselves a folder is created instead of a file
mkdir -p data
if [ ! -f ./data/hosts ]; then
  touch ./data/hosts
fi

docker-compose -f docker-compose.certificates.yml down -v
docker-compose -f docker-compose.certificates.yml rm -v
docker-compose -f docker-compose.certificates.yml up --no-build --abort-on-container-exit

zip -r data.zip data

echo "******************************"
echo "SUCCESS: certificates built"
echo "Download data.zip and unzip it"
echo "******************************"
