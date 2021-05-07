#!/bin/bash

set -eu


function generateconf() {
  export APP_URL=$1
  export PROTOCOL=$2
  URI=${APP_URL}${ENV}
  if [ ! -f /etc/nginx/conf.d/${URI}-$PROTOCOL.conf ]; then
    envsubst '${APP_URL} ${ENV} ${DOMAIN}' \
      < /etc/nginx/base_conf/app-$PROTOCOL.template \
      > /etc/nginx/conf.d/${URI}-$PROTOCOL.conf
  fi
}

ORG=""
if [ "$#" -ne 0 ]; then
  echo "Generating conf for $1"
  ORG="$1."
else
  echo "Generating main conf"
fi

generateconf ${ORG}${COMBO_SUBDOMAIN} http
generateconf ${ORG}${COMBO_ADMIN_SUBDOMAIN} http
generateconf ${ORG}${CHRONO_SUBDOMAIN} http
generateconf ${ORG}${FARGO_SUBDOMAIN} http
generateconf ${ORG}${AUTHENTIC_SUBDOMAIN} http
generateconf ${ORG}${HOBO_SUBDOMAIN} http
generateconf ${ORG}${WCS_SUBDOMAIN} http
generateconf ${ORG}${PASSERELLE_SUBDOMAIN} http

generateconf ${ORG}${COMBO_SUBDOMAIN} https
generateconf ${ORG}${COMBO_ADMIN_SUBDOMAIN} https
generateconf ${ORG}${CHRONO_SUBDOMAIN} https
generateconf ${ORG}${FARGO_SUBDOMAIN} https
generateconf ${ORG}${AUTHENTIC_SUBDOMAIN} https
generateconf ${ORG}${HOBO_SUBDOMAIN} https
generateconf ${ORG}${WCS_SUBDOMAIN} https
generateconf ${ORG}${PASSERELLE_SUBDOMAIN} https
