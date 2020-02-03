#!/bin/bash

sudo -u wcs wcs-manage import_site -d ${WCS_SUBDOMAIN}${ENV}.${DOMAIN} /var/lib/wcs/skeletons/publik.zip

if [ -f /tmp/publik-data/combo-site.json ]; then
  sudo -u combo combo-manage tenant_command import_site -d ${COMBO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} /tmp/publik-data/combo-site.json
fi

if [ -f /tmp/publik-data/combo-agent-site.json ]; then
  sudo -u combo combo-manage tenant_command import_site -d ${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} /tmp/publik-data/combo-agent-site.json
fi
