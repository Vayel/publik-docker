#!/bin/bash

set -eu

. ./init-env.sh

# If we don't create it ourselves a folder is created instead of a file
mkdir -p data
if [ ! -f ./data/hosts ]; then
  touch ./data/hosts
fi

docker-compose -f docker-compose.certificates.yml up --no-build --abort-on-container-exit

zip -r letsencrypt.zip data/letsencrypt

echo "**********************************************************"
echo "SUCCESS: certificates built"
echo "Download letsencrypt.zip and unzip it into the data folder"
echo "**********************************************************"
