#!/bin/bash

. ./manage/init-env.sh

. ./manage/colors.sh

if ! ./manage/check-version.sh; then
  echo_warning "WARNING: last-build commit different from current commit. Rebuild needed?"
  echo
fi

docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --no-build --abort-on-container-exit
