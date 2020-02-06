#!/bin/bash

URL_PREFIX=
ROOT_FOLDER=/tmp/sites
FOLDER=$ROOT_FOLDER

if [ "$#" -ne 0 ]; then
  ORG=$1
  URL_PREFIX="$ORG."
  FOLDER="/tmp/sites/$ORG"
fi

echo "Exporting user portal to $FOLDER/..."
sudo -u combo combo-manage tenant_command export_site -d ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} > "$FOLDER/user-portal.json"

echo "Exporting agent portal to $FOLDER/..."
sudo -u combo combo-manage tenant_command export_site -d ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} > "$FOLDER/agent-portal.json"

echo "Exporting auth to $ROOT_FOLDER/..."
sudo -u authentic-multitenant authentic2-multitenant-manage tenant_command export_site -d ${AUTHENTIC_SUBDOMAIN}${ENV}.${DOMAIN} > "$ROOT_FOLDER/auth.json"

echo "Please export wcs data from web interface:"
echo "* URL: https://${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN}"
echo "* Dest: $FOLDER/wcs.zip"
