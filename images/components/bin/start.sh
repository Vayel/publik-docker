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
#
# In the Dockerfile, we also define custom settings per component
subst.sh /tmp/common.py.template /tmp/_common.py
for COMP in authentic2-multitenant combo chrono fargo hobo hobo-agent passerelle wcs
do
  cp /tmp/_common.py "/etc/$COMP/settings.d/"
done

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

set-var-lib-ownership.sh

echo "*******************"
echo "Initializing themes"
echo "*******************"
echo
deploy-themes.sh

echo "*****************"
echo "Starting services"
echo "*****************"
echo
start-services.sh
