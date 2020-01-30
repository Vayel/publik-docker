#!/bin/sh

# https://doc-publik.entrouvert.com/guide-de-l-administrateur-systeme/installation/deploiement-des-instances/#verification-du-deploiement

check() {
  container=components
  folder=$1
  docker exec $container ls "$folder" >> /dev/null # Make sure folder exists
  if [ $? -ne 0 ]; then
    echo "ERROR: $folder on $container doesn't exist but should"
    exit 1
  fi
  c=`docker exec $container ls "$folder" | wc -l`
  if [ "$c" -eq "0" ]; then 
    echo "ERROR: $folder on $container is empty but shouldn't"
    exit 1
  fi
}

check "/var/lib/authentic2-multitenant/tenants"
check "/var/lib/combo/tenants"
check "/var/lib/fargo/tenants"
check "/var/lib/hobo/tenants"
check "/var/lib/passerelle/tenants"
check "/var/lib/wcs"

echo "Deployment looks OK"
