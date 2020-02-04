#!/bin/bash

# Fail on errors
set -eu

check-env.sh

# Wait for dependencies
wait-for-it.sh -t 60 $DB_HOST:${DB_PORT}
wait-for-it.sh -t 60 $RABBITMQ_HOST:${RABBITMQ_PORT}

echo "*********************"
echo "Initializing database"
echo "*********************"
init-database.sh

echo "*********************"
echo "Substituting env vars"
echo "*********************"
SUBST_STR='$DOMAIN $ADMIN_MAIL_ADDR $ADMIN_MAIL_AUTHOR $RABBITMQ_HOST $RABBITMQ_DEFAULT_USER $AUTHENTIC_SUBDOMAIN $COMBO_SUBDOMAIN $COMBO_ADMIN_SUBDOMAIN $FARGO_SUBDOMAIN $HOBO_SUBDOMAIN $PASSERELLE_SUBDOMAIN $WCS_SUBDOMAIN $LOG_LEVEL $DEFAULT_POSITION $BROKER_TASK_EXPIRES $DEBUG $ENV $ALLOWED_HOSTS $SMTP_USER $DB_ADMIN_USER $DB_HOST $DB_PORT $RABBITMQ_PORT $RABBITMQ_MANAGEMENT_PORT $HTTP_PORT $HTTPS_PORT $SMTP_HOST $SMTP_PORT $DOCKER_PROJECT_NAME $POSTGRES_PASSWORD $DB_AUTHENTIC_PASS $DB_COMBO_PASS $DB_FARGO_PASS $DB_HOBO_PASS $DB_PASSERELLE_PASS $DB_WCS_PASS $RABBITMQ_DEFAULT_PASS $SUPERUSER_PASS $SMTP_PASS'

# To pass env vars to Python scripts run by Publik in services which remove custom env vars:
# https://unix.stackexchange.com/questions/44370/how-to-make-unix-service-see-environment-variables
# So we hardcode the values in the file below when the container starts
#
# The common settings must be imported first by hobo, which uses the alphabetical order
# (hence the "_")
envsubst "$SUBST_STR" < /tmp/common.py.template > /tmp/_common.py
for COMP in authentic2-multitenant combo fargo hobo passerelle wcs
do
  envsubst "$SUBST_STR" < "/etc/nginx/conf.d/$COMP.template" > "/etc/nginx/conf.d/$COMP.conf"
  cp /tmp/_common.py "/etc/$COMP/settings.d/"
done
cp /tmp/_common.py /etc/hobo-agent/settings.d/

mkdir -p /tmp/wcs-template
envsubst "$SUBST_STR" < /tmp/wcs-config.json.template > /tmp/wcs-template/config.json
envsubst "$SUBST_STR" < /tmp/hobo-recipe.json.template > /tmp/hobo-recipe.json
zip -j /var/lib/wcs/skeletons/publik.zip /tmp/wcs-template/*

for path in /tmp/sites/*.template /tmp/sites/**/*.template
do
  # If there are no .template files, $path is equal to "/tmp/sites/*.template",
  # which doesn't exist
  if [ -f "$path" ]; then
    # Remove ".template"
    dest=${path::-9}
    envsubst "$SUBST_STR" < "$path" > "$dest"
  fi
done

# To be allowed to write logs
chown -R wcs:wcs /var/lib/wcs

echo "*****************"
echo "Starting services"
echo "*****************"
function check_services {
  for S in combo passerelle fargo hobo supervisor authentic2-multitenant wcs nginx
  do
    service $S status
    if [ $? -ne 0 ]; then
      service $S stop
      sleep 2
      service $S start
    fi
  done
}

service combo start
service passerelle start
service fargo start
service hobo start
service supervisor start
service authentic2-multitenant start
service wcs start
service nginx start

sleep 2

check_services
