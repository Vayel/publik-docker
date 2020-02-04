#!/bin/bash

ORG=
URL_PREFIX=
FOLDER=/tmp/sites
if [ "$#" -ne 0 ]; then
  ORG=$1
  URL_PREFIX="$ORG."
  FOLDER="/tmp/sites/$ORG"
fi

if [ -f "$FOLDER/wcs.zip" ]; then
  echo "Importing wcs from $FOLDER..."
  sudo -u wcs wcs-manage import_site -d ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/wcs.zip"
fi
sudo -u wcs wcs-manage import_site -d ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN} /var/lib/wcs/skeletons/publik.zip

if [ -f "$FOLDER/user-portal.json" ]; then
  echo "Importing user portal from $FOLDER..."
  sudo -u combo combo-manage tenant_command import_site -d ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/user-portal.json"
fi

if [ -f "$FOLDER/agent-portal.json" ]; then
  echo "Importing agent portal from $FOLDER..."
  sudo -u combo combo-manage tenant_command import_site -d ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/agent-portal.json"
fi
