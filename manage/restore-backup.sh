#!/bin/bash

BACKUP_DIR=$1

if [ -z "$BACKUP_DIR" ]; then
  echo "Usage: restore-backup.sh <path>"
  exit 1
fi

echo "The 'components' service must be stopped for the volumes to be available."
echo

read -p "Are you sure to restore $BACKUP_DIR? It will ERASE the actual data. [y/n] " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Operation aborted."
  exit 1
fi

# See docker-compose.restorer.yml
SRC_DIR=data/backups/to_restore
mkdir -p $SRC_DIR
rm -rf "$SRC_DIR/*"
cp -R $BACKUP_DIR/* $SRC_DIR

docker-compose -f docker-compose.restorer.yml up --abort-on-container-exit
