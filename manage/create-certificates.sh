#!/bin/bash

set -eu

. ./manage/colors.sh

. ./init-env.sh

docker-compose -f docker-compose.certificates.yml up --no-build --abort-on-container-exit

echo
echo_success "***************************************************************"
echo_success "SUCCESS: certificates built"
echo_success "Please run (needs sudo access):"
echo_success "cd /home/publik/publik-docker/data; sudo zip -r letsencrypt.zip letsencrypt"
echo_success "Download letsencrypt.zip and unzip it into the data folder"
echo_success "***************************************************************"
echo
