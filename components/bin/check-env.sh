#!/bin/bash

err=false

for VAR in LOG_LEVEL ADMIN_MAIL_ADDR ADMIN_MAIL_AUTHOR DOMAIN RABBITMQ_DEFAULT_USER POSTGRES_PASSWORD DB_HOBO_PASS DB_PASSERELLE_PASS DB_COMBO_PASS DB_FARGO_PASS DB_WCS_PASS DB_AUTHENTIC_PASS RABBITMQ_DEFAULT_PASS SUPERUSER_PASS DB_HOST DB_PORT DB_ADMIN_USER RABBITMQ_HOST RABBITMQ_PORT RABBITMQ_MANAGEMENT_PORT HTTP_PORT HTTPS_PORT SMTP_USER SMTP_PASS SMTP_HOST SMTP_PORT AUTHENTIC_SUBDOMAIN COMBO_SUBDOMAIN COMBO_ADMIN_SUBDOMAIN FARGO_SUBDOMAIN HOBO_SUBDOMAIN PASSERELLE_SUBDOMAIN WCS_SUBDOMAIN ALLOWED_HOSTS
do
  if [ -z "${!VAR}" ]
  then
    echo "ERROR: $VAR MUST be set and MUST NOT be empty"
    err=true
  fi
done

for VAR in ENV DEBUG
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
