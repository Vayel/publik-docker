#!/bin/bash

set -eu

DIR_NAME=`date +"%d-%m-%Y_%Hh%Mm%Ss"`
BACKUP_DIR="data/backups/$DIR_NAME"
mkdir -p "$BACKUP_DIR"

docker exec components backup.sh
cp -R data/backups/last/* $BACKUP_DIR

echo && echo "Backup successfully stored in $BACKUP_DIR"
