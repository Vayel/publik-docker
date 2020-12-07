#!/bin/bash

. ./manage/colors.sh

./manage/backup.sh
# no-cache so that debian packages are updated
./manage/docker/build.sh --no-cache
./manage/docker/down.sh

echo_success "Update finished. Please up the services."
