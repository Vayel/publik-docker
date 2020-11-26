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

sudo -u hobo hobo-manage delete_tenant ${ORG}.${HOBO_SUBDOMAIN}.${DOMAIN}
sudo -u combo combo-manage delete_tenant ${ORG}.${COMBO_SUBDOMAIN}.${DOMAIN}
sudo -u combo combo-manage delete_tenant ${ORG}.${COMBO_ADMIN_SUBDOMAIN}.${DOMAIN}
sudo -u passerelle passerelle-manage delete_tenant ${ORG}.${PASSERELLE_SUBDOMAIN}.${DOMAIN}
sudo -u fargo fargo-manage delete_tenant ${ORG}.${FARGO_SUBDOMAIN}.${DOMAIN}
sudo rm -rf /var/lib/wcs/${ORG}.${WCS_SUBDOMAIN}.${DOMAIN}
