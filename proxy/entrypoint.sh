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
	export APP_LINK=$2
	if [ ! -f /etc/nginx/conf.d/${APP_URL}-$3.conf ]; then
		envsubst '${APP_URL} ${APP_LINK} ${ENV} ${DOMAIN}' \
			< /etc/nginx/conf.d/app-$3.template \
			> /etc/nginx/conf.d/${APP_URL}-$3.conf
	fi
}

function generatecertificate() {
	if [ ! -d /etc/letsencrypt/live/$1${ENV}.${DOMAIN} ]; then
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
    ORG="$1."
  fi

  generateconf ${ORG}${COMBO_SUBDOMAIN} combo http
  generateconf ${ORG}${COMBO_ADMIN_SUBDOMAIN} combo http
  generateconf ${ORG}${FARGO_SUBDOMAIN} fargo http
  generateconf ${ORG}${AUTHENTIC_SUBDOMAIN} authentic http
  generateconf ${ORG}${HOBO_SUBDOMAIN} hobo http
  generateconf ${ORG}${WCS_SUBDOMAIN} wcs http
  generateconf ${ORG}${PASSERELLE_SUBDOMAIN} passerelle http

  generatecertificate ${ORG}${COMBO_SUBDOMAIN}
  generatecertificate ${ORG}${COMBO_ADMIN_SUBDOMAIN}
  generatecertificate ${ORG}${FARGO_SUBDOMAIN}
  generatecertificate ${ORG}${AUTHENTIC_SUBDOMAIN}
  generatecertificate ${ORG}${HOBO_SUBDOMAIN}
  generatecertificate ${ORG}${WCS_SUBDOMAIN}
  generatecertificate ${ORG}${PASSERELLE_SUBDOMAIN}

  generateconf ${ORG}${COMBO_SUBDOMAIN} combo https
  generateconf ${ORG}${COMBO_ADMIN_SUBDOMAIN} combo https
  generateconf ${ORG}${FARGO_SUBDOMAIN} fargo https
  generateconf ${ORG}${AUTHENTIC_SUBDOMAIN} authentic https
  generateconf ${ORG}${HOBO_SUBDOMAIN} hobo https
  generateconf ${ORG}${WCS_SUBDOMAIN} wcs https
  generateconf ${ORG}${PASSERELLE_SUBDOMAIN} passerelle https
}

generateall

# Generate certificates for organizations
if [ -d "/tmp/site/recipes" ]; then
  cd /tmp/site/recipes
  for path in *.template
  do
    # If there are no .template files, $path is equal to "/tmp/site/*.template",
    # which doesn't exist
    if [ -f "$path" ]; then
      # Remove ".json.template"
      org=${path::-14}
      generateall "$org"
    fi
  done
fi

# Start NGINX (Log on screen)
nginx -g 'daemon off;'

exec "$@"
