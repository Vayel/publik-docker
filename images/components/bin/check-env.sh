#!/bin/bash

err=false

for VAR in LOG_LEVEL ADMIN_MAIL_ADDR ADMIN_MAIL_AUTHOR DOMAIN RABBITMQ_USER PASS_POSTGRES PASS_DB_HOBO PASS_DB_PASSERELLE PASS_DB_COMBO PASS_DB_FARGO PASS_DB_WCS PASS_DB_AUTHENTIC PASS_RABBITMQ PASS_SUPERUSER DB_HOST DB_PORT DB_ADMIN_USER RABBITMQ_HOST RABBITMQ_PORT RABBITMQ_MANAGEMENT_PORT HTTP_PORT HTTPS_PORT SMTP_HOST SMTP_PORT AUTHENTIC_SUBDOMAIN COMBO_SUBDOMAIN COMBO_ADMIN_SUBDOMAIN FARGO_SUBDOMAIN HOBO_SUBDOMAIN PASSERELLE_SUBDOMAIN WCS_SUBDOMAIN ALLOWED_HOSTS HOBO_DEPLOY_TIMEOUT HOBO_DEPLOY_VERBOSITY ORG_DEFAULT_THEME
do
  if [ -z "${!VAR}" ]
  then
    echo "ERROR: $VAR MUST be set and MUST NOT be empty"
    err=true
  fi
done

for VAR in ENV DEBUG SMTP_USER PASS_SMTP
do
  if [ -z "${!VAR+x}" ]
  then
    echo "ERROR: $VAR MUST be set"
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
