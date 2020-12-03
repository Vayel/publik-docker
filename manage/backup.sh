#!/bin/bash

set -eu

DIR_NAME=`date +"%d-%m-%Y_%Hh%Mm%Ss"`
BACKUP_DIR="data/backups/$DIR_NAME"
mkdir -p "$BACKUP_DIR"

docker exec components bash -c "cd /var/lib && tar cvf /tmp/backup_var_lib.tar authentic2-multitenant combo fargo hobo passerelle wcs"
docker cp components:/tmp/backup_var_lib.tar "$BACKUP_DIR/var_lib.tar"

docker exec components dump_db.sh
docker cp components:/tmp/db_dump.gz "$BACKUP_DIR"

[ $? -eq 0 ] && echo && echo "Backup successfully stored in $BACKUP_DIR"
