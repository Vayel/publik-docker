#!/bin/bash

. colors.sh

# Fail on errors
set -eu

check-env.sh

# Wait for dependencies
wait-for-it.sh -t 60 $DB_HOST:${DB_PORT}
wait-for-it.sh -t 60 $RABBITMQ_HOST:${RABBITMQ_PORT}

echo "*********************"
echo "Initializing database"
echo "*********************"
echo
init-database.sh

echo "*********************"
echo "Substituting env vars"
echo "*********************"
echo

# To pass env vars to Python scripts run by Publik in services which remove custom env vars:
# https://unix.stackexchange.com/questions/44370/how-to-make-unix-service-see-environment-variables
# So we hardcode the values in the file below when the container starts
#
# The common settings must be imported first by hobo, which uses the alphabetical order
# (hence the "_")
subst.sh /tmp/common.py.template /tmp/_common.py
for COMP in authentic2-multitenant combo fargo hobo passerelle wcs
do
  cp /tmp/_common.py "/etc/$COMP/settings.d/"
done
cp /tmp/_common.py /etc/hobo-agent/settings.d/

# To be allowed to write logs
chown -R wcs:wcs /var/lib/wcs

config-nginx.sh
for dir in /tmp/sites/*/
do
  if [ -d "$dir" ]; then
    ORG=${dir:11:-1}
    if [ "${ORG:0:1}" != "_" ]; then
      config-nginx.sh $ORG
    fi
  fi
done

echo "*****************"
echo "Starting services"
echo "*****************"
echo
function check_services {
  for S in memcached combo passerelle fargo hobo supervisor authentic2-multitenant wcs nginx
  do
    # We use the "or" to avoid exiting the script if the status returns a non-zero
    # code
    ret_code=0
    service $S status || ret_code=$?

    if [ "$ret_code" != '0' ]; then
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
echo_info "If all services are running, call ./manage/publik/deploy.sh in another shell"
