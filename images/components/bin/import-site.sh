#!/bin/bash

. colors.sh

ORG=
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

#
# WCS
#
# We do not import WCS, otherwise we would override the config built during the
# deployment (e.g. the database name)

#
# User portal
#
if [ -f "$FOLDER/user-portal.json" ]; then
  echo "Importing user portal from $FOLDER/..."
  sudo -u combo combo-manage tenant_command import_site -d ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/user-portal.json"
elif [ -f "$ROOT_FOLDER/user-portal.json" ]; then
  echo "Importing user portal from $ROOT_FOLDER/..."
  sudo -u combo combo-manage tenant_command import_site -d ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} "$ROOT_FOLDER/user-portal.json"
fi

#
# Agent portal
#
if [ -f "$FOLDER/agent-portal.json" ]; then
  echo "Importing agent portal from $FOLDER/..."
  sudo -u combo combo-manage tenant_command import_site -d ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/agent-portal.json"
elif [ -f "$ROOT_FOLDER/agent-portal.json" ]; then
  echo "Importing agent portal from $ROOT_FOLDER/..."
  sudo -u combo combo-manage tenant_command import_site -d ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} "$ROOT_FOLDER/agent-portal.json"
fi

#
# Categories, forms and workflows
#
# Warning: workflows CANNOT refer to roles as they are not imported yet
# Forms also need a role to be created
for fname in categories # workflows forms
do
  if [ -f "$FOLDER/$fname.zip" ]; then
    echo "Importing $fname from $FOLDER/..."
    sudo -u wcs wcs-manage import_site -d ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN} "$FOLDER/$fname.zip"
  fi
done

echo_success "Site successfully imported. You can now import categories, workflows and forms from the web interface."
