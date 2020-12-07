#!/bin/bash

. colors.sh

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
    echo_error "ERROR: $VAR MUST be set and MUST NOT be empty"
    err=true
  fi
done

if [ "$err" = true ]
then
  echo_error "***************************************************************"
  echo_error "ERROR: some env vars are invalid. See the error messages above."
  echo_error "***************************************************************"
  echo
  exit 1
fi

envsubst '$ENV $DOMAIN $RABBITMQ_MANAGEMENT_PORT' < /etc/nginx/conf.d/rabbitmq.template \
	> /etc/nginx/conf.d/rabbitmq.conf

if [ ! -z "$PGADMIN_PORT" ];
then
  envsubst '${ENV} ${DOMAIN} $PGADMIN_PORT' < /etc/nginx/conf.d/pgadmin.template \
	  > /etc/nginx/conf.d/pgadmin.conf
fi

if [ ! -z "$MAILCATCHER_HTTP_PORT" ]; then
  envsubst '${ENV} ${DOMAIN} $MAILCATCHER_HTTP_PORT' < /etc/nginx/conf.d/mailcatcher.template \
	  > /etc/nginx/conf.d/mailcatcher.conf
fi

configure.sh

# Generate certificates for organizations
if [ -d "/tmp/sites" ]; then
  for dir in /tmp/sites/*/
  do
    if [ -d "$dir" ]; then
      ORG=${dir:11:-1}
      if [ "${ORG:0:1}" != "_" ]; then
        configure.sh $ORG
      fi
    fi
  done
fi

function update_certificates {
  while true
  do
    date > /tmp/cert-renew.log
    update-certificates.sh &>> /tmp/cert-renew.log
    sleep 12h
  done
}

update_certificates & # Run in background

# Execute Docker command
exec "$@"
