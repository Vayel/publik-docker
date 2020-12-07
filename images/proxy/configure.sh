#!/bin/bash

. colors.sh

# Fail on errors
set -eu

function generateconf() {
	export APP_URL=$1
  export PROTOCOL=$2
  URI=${APP_URL}${ENV}
	if [ ! -f /etc/nginx/conf.d/${URI}-$PROTOCOL.conf ]; then
		envsubst '${APP_URL} ${ENV} ${DOMAIN}' \
			< /etc/nginx/conf.d/app-$PROTOCOL.template \
			> /etc/nginx/conf.d/${URI}-$PROTOCOL.conf
	fi
}

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

function generateall() {
  ORG=""
  if [ "$#" -ne 0 ]; then
    echo "Generating conf for $1"
    ORG="$1."
  else
    echo "Generating main conf"
  fi

  generateconf ${ORG}${COMBO_SUBDOMAIN} http
  generateconf ${ORG}${COMBO_ADMIN_SUBDOMAIN} http
  generateconf ${ORG}${FARGO_SUBDOMAIN} http
  generateconf ${ORG}${AUTHENTIC_SUBDOMAIN} http
  generateconf ${ORG}${HOBO_SUBDOMAIN} http
  generateconf ${ORG}${WCS_SUBDOMAIN} http
  generateconf ${ORG}${PASSERELLE_SUBDOMAIN} http

  generatecertificate ${ORG}${COMBO_SUBDOMAIN}
  generatecertificate ${ORG}${COMBO_ADMIN_SUBDOMAIN}
  generatecertificate ${ORG}${FARGO_SUBDOMAIN}
  generatecertificate ${ORG}${AUTHENTIC_SUBDOMAIN}
  generatecertificate ${ORG}${HOBO_SUBDOMAIN}
  generatecertificate ${ORG}${WCS_SUBDOMAIN}
  generatecertificate ${ORG}${PASSERELLE_SUBDOMAIN}

  generateconf ${ORG}${COMBO_SUBDOMAIN} https
  generateconf ${ORG}${COMBO_ADMIN_SUBDOMAIN} https
  generateconf ${ORG}${FARGO_SUBDOMAIN} https
  generateconf ${ORG}${AUTHENTIC_SUBDOMAIN} https
  generateconf ${ORG}${HOBO_SUBDOMAIN} https
  generateconf ${ORG}${WCS_SUBDOMAIN} https
  generateconf ${ORG}${PASSERELLE_SUBDOMAIN} https

  echo_success 'Configuration generated!'
}

if [ "$#" -eq 0 ]; then
  generateall
else
  generateall $1
fi
