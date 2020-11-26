#!/bin/bash

ORG=$1

if [ -z "$ORG" ]; then
  echo "Usage: delete-org.sh <slug>"
  exit 1
fi

read -p "Are you sure to delete ${ORG}? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  exit 1
fi

function delete_tenant() {
  SERVICE=$1
  CMD=$3
  if [ -z "$CMD" ]; then
    CMD="${SERVICE}-manage"
  fi
  TENANT="${ORG}.$2.${DOMAIN}"
  echo
  echo "Deleting $TENANT"
  sudo -u $SERVICE $CMD delete_tenant $TENANT --force-drop
}

# In the reverse order of hobo-recipe
delete_tenant fargo ${FARGO_SUBDOMAIN}
delete_tenant wcs ${WCS_SUBDOMAIN} wcsctl
delete_tenant passerelle ${PASSERELLE_SUBDOMAIN}
delete_tenant combo ${COMBO_ADMIN_SUBDOMAIN}
delete_tenant combo ${COMBO_SUBDOMAIN}
delete_tenant hobo ${HOBO_SUBDOMAIN}
