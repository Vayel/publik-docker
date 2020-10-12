#!/bin/bash

set -eu

mkdir -p data/backups
docker exec components bash -c "cd /var/lib && tar cvf /tmp/backups/components.tar authentic2-multitenant combo fargo hobo passerelle wcs"
#docker run --rm --volumes-from components -v $PWD/backups:/backups ubuntu bash -c "cd /var/lib && tar cvf /backups/components.tar authentic2-multitenant combo fargo hobo passerelle wcs"
