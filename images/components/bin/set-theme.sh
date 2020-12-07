#!/bin/bash

ORG=global
URL_PREFIX=

if [ "$#" -eq 1 ]; then
  THEME=$1
elif [ "$#" -eq 2 ]; then
  THEME=$1
  ORG=$2
  URL_PREFIX="$ORG."
else
  echo "Help:"
  echo "  set-theme.sh <theme> [<org>]"
  echo "Examples:"
  echo "  set-theme.sh my-global-theme"
  echo "  set-theme.sh my-org-theme my-org"
  exit 1
fi

THEME_PATH="/usr/share/publik/themes/$THEME"
if [ ! -d "$THEME_PATH" ]; then
  >&2 echo "Theme $THEME_PATH does not exist. Is the 'themes' folder mounted?"
  exit 1
fi

echo "Setting theme $THEME to org $ORG"

export THEME
envsubst '$THEME' < /tmp/hobo-theme.json.template > /tmp/hobo-theme.json

sudo -u hobo hobo-manage tenant_command cook /tmp/hobo-theme.json -d ${URL_PREFIX}${HOBO_SUBDOMAIN}${ENV}.${DOMAIN} -v 2 --timeout=${HOBO_DEPLOY_TIMEOUT}
