#!/bin/bash

set -eu

. ./init-env.sh

docker-compose -f docker-compose.certificates.yml up --no-build --abort-on-container-exit

echo "***************************************************************"
echo "SUCCESS: certificates built"
echo "Please run (needs sudo access):"
echo "cd /home/publik/publik-docker/data; sudo zip -r letsencrypt.zip letsencrypt"
echo "Download letsencrypt.zip and unzip it into the data folder"
echo "***************************************************************"
