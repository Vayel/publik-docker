#!/bin/bash

set -eu

. ./init-env.sh

# If we don't create it ourselves a folder is created instead of a file
mkdir -p data
if [ ! -f ./data/hosts ]; then
  touch ./data/hosts
fi

docker-compose -f docker-compose.certificates.yml up --no-build --abort-on-container-exit

echo "***************************************************************"
echo "SUCCESS: certificates built"
echo "Please run (need sudo access):"
echo "cd /home/publik/publik-docker/data; sudo zip -r letsencrypt.zip letsencrypt"
echo "Download letsencrypt.zip and unzip it into the data folder"
echo "***************************************************************"
