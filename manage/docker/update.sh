#!/bin/bash

. ./manage/colors.sh

DEST_DIR=data/previous-packages-versions.txt

rm -f $DEST_DIR

echo_warning "It's recommended to do a backup first."
echo

echo "If containers are up, package versions before update are saved to $DEST_DIR"
./manage/publik/show-packages-versions.sh > $DEST_DIR

set -eu

echo
git pull --recurse-submodules
# no-cache so that debian packages are updated
./manage/docker/build.sh --no-cache

echo
echo_success "Update finished. Please restart the services."
echo "Then, and only then, you might want to prune old Docker images as well: https://docs.docker.com/config/pruning/"
