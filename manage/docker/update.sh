#!/bin/bash

set -eu

. ./manage/colors.sh

echo "Package versions before update:"
echo
./manage/publik/list-component-versions.sh
echo
./manage/backup.sh
# no-cache so that debian packages are updated
./manage/docker/build.sh --no-cache
./manage/docker/down.sh

echo_success "Update finished. Please up the services."
