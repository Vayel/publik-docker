#!/bin/bash

set -eu

. ./manage/colors.sh

DEST_DIR=data/previous-packages-versions.txt

rm -f $DEST_DIR

echo "Package versions before update are saved to $DEST_DIR"
./manage/publik/show-packages-versions.sh > $DEST_DIR
echo
git pull --recurse-submodules
./manage/backup.sh
# no-cache so that debian packages are updated
./manage/docker/build.sh --no-cache
./manage/docker/down.sh

echo_success "Update finished. Please up the services."
