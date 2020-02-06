#!/bin/bash

# Fail on errors
set -eu

# Create HTTP home
mkdir -p /home/http
chmod 777 /home/http

err=false
for VAR in DOMAIN RABBITMQ_MANAGEMENT_PORT ADMIN_MAIL_ADDR
do
  if [ -z "${!VAR}" ]
  then
    echo "ERROR: $VAR MUST be set and MUST NOT be empty"
    err=true
  fi
done

if [ "$err" = true ]
then
  echo "***************************************************************"
  echo "ERROR: some env vars are invalid. See the error messages above."
  echo "***************************************************************"
  exit 1
fi

# Add tools to NGINX (pgadmin, ...)
envsubst '${ENV} ${DOMAIN} ${RABBITMQ_MANAGEMENT_PORT}' < /etc/nginx/conf.d/tools.template \
	> /etc/nginx/conf.d/tools.conf

# Create NGINX configuration for Publik containers
function generateconf() {
	export APP_URL=$1
  export PROTOCOL=$2
	if [ ! -f /etc/nginx/conf.d/${APP_URL}-$PROTOCOL.conf ]; then
		envsubst '${APP_URL} ${ENV} ${DOMAIN}' \
			< /etc/nginx/conf.d/app-$PROTOCOL.template \
			> /etc/nginx/conf.d/${APP_URL}-$PROTOCOL.conf
	fi
}

function generatecertificate() {
	if [ ! -d /etc/letsencrypt/live/$1${ENV}.${DOMAIN} ]; then
    echo "generating $1"
		service nginx start
    # https://certbot.eff.org/docs/using.html#certbot-command-line-options
		certbot certonly --webroot -n --agree-tos \
			-w /home/http \
			-d $1${ENV}.${DOMAIN} \
			--email ${ADMIN_MAIL_ADDR}
		service nginx stop
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
}

generateall

# Generate certificates for organizations
if [ -d "/tmp/sites" ]; then
  for dir in /tmp/sites/*/
  do
    if [ -d "$dir" ]; then
      ORG=${dir:11:-1}
      if [ "${ORG:0:1}" != "_" ]; then
        generateall $ORG
      fi
    fi
  done
fi

# Execute Docker command
exec "$@"
