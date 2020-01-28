#!/bin/bash

# Fail on errors
set -eu

# Wait for dependencies
/root/wait-for-it.sh -t 60 db:${DB_PORT}
/root/wait-for-it.sh -t 60 rabbitmq:${RABBITMQ_PORT}

/root/check-env.sh

for COMP in authentic combo fargo hobo passerelle wcs
do
  envsubst '${ENV} ${DOMAIN} $AUTHENTIC_SUBDOMAIN $COMBO_SUBDOMAIN $COMBO_ADMIN_SUBDOMAIN $FARGO_SUBDOMAIN $HOBO_SUBDOMAIN $PASSERELLE_SUBDOMAIN $WCS_SUBDOMAIN' < "/etc/nginx/conf.d/$COMP.template" > "/etc/nginx/conf.d/$COMP.conf"
done

# Cannot use "settings.py" as it seems to be in conflict with Django's settings
envsubst '$DEBUG $LOG_LEVEL $ALLOWED_HOSTS $DB_PORT $DB_HOBO_PASS $DB_PASSERELLE_PASS $DB_COMBO_PASS $DB_FARGO_PASS $DB_WCS_PASS $DB_AUTHENTIC_PASS $RABBITMQ_DEFAULT_USER $RABBITMQ_DEFAULT_PASS $RABBITMQ_PORT $ADMIN_MAIL_AUTHOR $ADMIN_MAIL_ADDR $SMTP_HOST $SMTP_USER $SMTP_PASS $SMTP_PORT' < /home/settings.template > /home/publik_settings.py
# Needs to be in a directory that can be read by a non-root user, so not "/root"
chmod 755 /home/publik_settings.py

envsubst '${EMAIL} ${ENV} ${DOMAIN} ${HTTPS_PORT} ${DB_WCS_PASS} $COMBO_SUBDOMAIN' < /tmp/config.template > /tmp/config.json
envsubst '${EMAIL} ${ENV} ${DOMAIN} ${HTTPS_PORT} ${SUPERUSER_PASS} $AUTHENTIC_SUBDOMAIN $COMBO_SUBDOMAIN $COMBO_ADMIN_SUBDOMAIN $FARGO_SUBDOMAIN $HOBO_SUBDOMAIN $PASSERELLE_SUBDOMAIN $WCS_SUBDOMAIN' < /tmp/hobo.recipe.template > /tmp/recipe.json
envsubst '${EMAIL} ${ENV} ${DOMAIN} ${HTTPS_PORT} $AUTHENTIC_SUBDOMAIN $COMBO_SUBDOMAIN $COMBO_ADMIN_SUBDOMAIN $FARGO_SUBDOMAIN $HOBO_SUBDOMAIN $PASSERELLE_SUBDOMAIN $WCS_SUBDOMAIN' < /tmp/cook.sh.template > /tmp/cook.sh
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
