#!/bin/bash

. colors.sh

if [ -z "$THEMES_REPO_URL" ]; then
  echo_warning "THEMES_REPO_URL variable not set, no themes imported."
  exit
fi

BASE_THEME_DIR=/usr/share/publik/publik-base-theme

cd /tmp
# No need to --recurse-submodules as the publik-base-theme repo was pulled in the
# Docker image
git clone $THEMES_REPO_URL publik-themes
cd publik-themes
rsync $BASE_THEME_DIR/* publik-base-theme --exclude .git
./deploy.sh
