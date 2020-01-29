#!/bin/bash

# Fail on errors
set -eu

# Wait for dependencies
wait-for-it.sh -t 60 db:${DB_PORT}
wait-for-it.sh -t 60 rabbitmq:${RABBITMQ_PORT}

check-env.sh

SUBST_STR='$DOMAIN $ADMIN_MAIL_ADDR $ADMIN_MAIL_AUTHOR $RABBITMQ_DEFAULT_USER $AUTHENTIC_SUBDOMAIN $COMBO_SUBDOMAIN $COMBO_ADMIN_SUBDOMAIN $FARGO_SUBDOMAIN $HOBO_SUBDOMAIN $PASSERELLE_SUBDOMAIN $WCS_SUBDOMAIN $LOG_LEVEL $DEFAULT_POSITION $BROKER_TASK_EXPIRES $DEBUG $ENV $ALLOWED_HOSTS $SMTP_USER $DB_PORT $RABBITMQ_PORT $RABBITMQ_MANAGEMENT_PORT $HTTP_PORT $HTTPS_PORT $SMTP_HOST $SMTP_PORT $MAILCATCHER_HTTP_PORT $PGADMIN_PORT $DOCKER_PROJECT_NAME $POSTGRES_PASSWORD $DB_AUTHENTIC_PASS $DB_COMBO_PASS $DB_FARGO_PASS $DB_HOBO_PASS $DB_PASSERELLE_PASS $DB_WCS_PASS $RABBITMQ_DEFAULT_PASS $SUPERUSER_PASS $SMTP_PASS'

for COMP in authentic combo fargo hobo passerelle wcs
do
  envsubst "$SUBST_STR" < "/etc/nginx/conf.d/$COMP.template" > "/etc/nginx/conf.d/$COMP.conf"
done

# Cannot use "settings.py" as it seems to be in conflict with Django's settings
# Needs to be in a directory that can be read by a non-root user, so not "/root"
envsubst "$SUBST_STR" < /home/settings.template > /home/publik_settings.py
chmod 755 /home/publik_settings.py

mkdir -p /tmp/wcs-template
envsubst "$SUBST_STR" < /tmp/config.template > /tmp/wcs-template/config.json
envsubst "$SUBST_STR" < /tmp/hobo.recipe.template > /tmp/recipe.json
envsubst "$SUBST_STR" < /tmp/cook.sh.template > /tmp/cook.sh
chmod +x /tmp/cook.sh

# To be allowed to write logs
chown -R wcs:wcs /var/lib/wcs

service combo start
service passerelle start
service fargo start
service hobo start
service supervisor start
service authentic2-multitenant start
service wcs start
service nginx start

sleep 2

service combo status
service passerelle status
service fargo status
service hobo status
service supervisor status
service authentic2-multitenant status
service wcs status
service nginx status
