#!/bin/bash

. colors.sh

if [ -z "$THEMES_REPO_URL" ]; then
  echo_warning "THEMES_REPO_URL variable not set, no themes imported."
  exit
fi

cd /tmp
git clone $THEMES_REPO_URL --recurse-submodules publik-themes
cd publik-themes
./deploy.sh
