#!/bin/bash

FOLDER=/tmp/site

if [ -f "$FOLDER/wcs.zip" ]; then
  echo "Importing wcs..."
  sudo -u wcs wcs-manage import_site -d ${WCS_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/wcs.zip"
fi
sudo -u wcs wcs-manage import_site -d ${WCS_SUBDOMAIN}${ENV}.${DOMAIN} /var/lib/wcs/skeletons/publik.zip

if [ -f "$FOLDER/user-portal.json" ]; then
  echo "Importing user portal..."
  sudo -u combo combo-manage tenant_command import_site -d ${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/user-portal.json"
fi

if [ -f "$FOLDER/agent-portal.json" ]; then
  echo "Importing agent portal..."
  sudo -u combo combo-manage tenant_command import_site -d ${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/agent-portal.json"
fi
