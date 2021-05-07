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

configure.sh

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
