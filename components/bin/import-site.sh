#!/bin/bash

FOLDER=/tmp/site

if [ -f "$FOLDER/wcs.zip" ]; then
  echo "Importing wcs..."
  sudo -u wcs wcs-manage import_site -d ${WCS_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/wcs.zip"
fi
sudo -u wcs wcs-manage import_site -d ${WCS_SUBDOMAIN}${ENV}.${DOMAIN} /var/lib/wcs/skeletons/publik.zip

FOLDER=/tmp/site

if [ -f "$FOLDER/combo-site.json" ]; then
  echo "Importing user portal..."
  sudo -u combo combo-manage tenant_command import_site -d ${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/combo-site.json"
fi

if [ -f "$FOLDER/combo-agent-site.json" ]; then
  echo "Importing agent portal..."
  sudo -u combo combo-manage tenant_command import_site -d ${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/combo-agent-site.json"
fi
