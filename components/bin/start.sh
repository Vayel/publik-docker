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

# To pass env vars to Python scripts run by Publik in services which remove custom env vars:
# https://unix.stackexchange.com/questions/44370/how-to-make-unix-service-see-environment-variables
# So we hardcode the values in the file below when the container starts
#
# The common settings must be imported first by hobo, which uses the alphabetical order
# (hence the "_")
subst.sh /tmp/common.py.template /tmp/_common.py
for COMP in authentic2-multitenant combo fargo hobo passerelle wcs
do
  subst.sh "/etc/nginx/conf.d/$COMP.template" "/etc/nginx/conf.d/$COMP.conf"
  cp /tmp/_common.py "/etc/$COMP/settings.d/"
done
cp /tmp/_common.py /etc/hobo-agent/settings.d/

mkdir -p /tmp/wcs-template
subst.sh /tmp/wcs-config.json.template /tmp/wcs-template/config.json
subst.sh /tmp/hobo-recipe.json.template /tmp/hobo-recipe.json
zip -j /var/lib/wcs/skeletons/publik.zip /tmp/wcs-template/*

# To be allowed to write logs
chown -R wcs:wcs /var/lib/wcs

echo "*****************"
echo "Starting services"
echo "*****************"
function check_services {
  for S in memcached combo passerelle fargo hobo supervisor authentic2-multitenant wcs nginx
  do
    service $S status
    if [ $? -ne 0 ]; then
      service $S stop
      sleep 2
      service $S start
    fi
  done
}

service memcached start
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
