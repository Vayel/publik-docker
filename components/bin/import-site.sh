#!/bin/bash

URL_PREFIX=
ROOT_FOLDER=/tmp/sites
FOLDER=$ROOT_FOLDER

if [ "$#" -ne 0 ]; then
  ORG=$1
  URL_PREFIX="$ORG."
  FOLDER="/tmp/sites/$ORG"
fi

# TODO: gives "Le sous-système d’authentification n’est pas encore configuré" for wcs
#if [ -z "$URL_PREFIX" ] && [ -f "$ROOT_FOLDER/auth.json" ]; then
#  echo "Importing auth from $ROOT_FOLDER/..."
#  sudo -u authentic-multitenant authentic2-multitenant-manage tenant_command import_site -d ${AUTHENTIC_SUBDOMAIN}${ENV}.${DOMAIN} "$ROOT_FOLDER/auth.json"
#fi

if [ -f "$FOLDER/wcs.zip" ]; then
  echo "Importing wcs from $FOLDER/..."
  sudo -u wcs wcs-manage import_site -d ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/wcs.zip"
fi
sudo -u wcs wcs-manage import_site -d ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN} /var/lib/wcs/skeletons/publik.zip

if [ -f "$FOLDER/user-portal.json" ]; then
  echo "Importing user portal from $FOLDER/..."
  sudo -u combo combo-manage tenant_command import_site -d ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/user-portal.json"
elif [ -f "$ROOT_FOLDER/user-portal.json" ]; then
  echo "Importing user portal from $ROOT_FOLDER/..."
  sudo -u combo combo-manage tenant_command import_site -d ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} "$ROOT_FOLDER/user-portal.json"
fi

if [ -f "$FOLDER/agent-portal.json" ]; then
  echo "Importing agent portal from $FOLDER/..."
  sudo -u combo combo-manage tenant_command import_site -d ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/agent-portal.json"
elif [ -f "$ROOT_FOLDER/agent-portal.json" ]; then
  echo "Importing agent portal from $ROOT_FOLDER/..."
  sudo -u combo combo-manage tenant_command import_site -d ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} "$ROOT_FOLDER/agent-portal.json"
fi
