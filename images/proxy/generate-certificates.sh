#!/bin/bash

set -eu


function generatecertificate() {
  URI=$1${ENV}.${DOMAIN}
  if [ ! -d /etc/letsencrypt/live/$URI ]; then
    echo "Generating $URI"

    # If nginx is already started, the command returns an error
    # We use the "or" to avoid exiting the script
    ret_code=0
    service nginx start || ret_code=$?

    # https://certbot.eff.org/docs/using.html#certbot-command-line-options
    certbot certonly --webroot -n --agree-tos \
      -w /home/http \
      -d $URI \
      --email ${ADMIN_MAIL_ADDR}

    if [ "$ret_code" == "0" ]; then
      service nginx stop
    fi
  fi
}

ORG=""
if [ "$#" -ne 0 ]; then
  echo "Generating certificates for $1"
  ORG="$1."
else
  echo "Generating main certificates"
fi

generatecertificate ${ORG}${COMBO_SUBDOMAIN}
generatecertificate ${ORG}${COMBO_ADMIN_SUBDOMAIN}
generatecertificate ${ORG}${CHRONO_SUBDOMAIN}
generatecertificate ${ORG}${FARGO_SUBDOMAIN}
generatecertificate ${ORG}${AUTHENTIC_SUBDOMAIN}
generatecertificate ${ORG}${HOBO_SUBDOMAIN}
generatecertificate ${ORG}${WCS_SUBDOMAIN}
generatecertificate ${ORG}${PASSERELLE_SUBDOMAIN}
