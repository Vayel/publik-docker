#!/bin/bash

BACKUP_DIR=$1
DEV=false

if [ -z "$BACKUP_DIR" ]; then
  echo "Usage: restore-backup.sh <path> [--dev]"
  exit 1
fi

if [ "$2" == "--dev" ]; then
  DEV=true
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
rm -rf $SRC_DIR/*
cp -R $BACKUP_DIR/* $SRC_DIR

if [ $DEV ]; then
  docker-compose -f docker-compose.restorer.yml -f docker-compose.restorer.dev.yml up --abort-on-container-exit
  docker-compose -f docker-compose.restorer.yml -f docker-compose.restorer.dev.yml rm -f
else
  docker-compose -f docker-compose.restorer.yml up --abort-on-container-exit
  docker-compose -f docker-compose.restorer.yml rm -f
fi
