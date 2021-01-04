#!/bin/bash

BACKUP_DIR=$1

if [ -z "$BACKUP_DIR" ]; then
  echo "Usage: restore-backup.sh <path>"
  exit 1
fi

read -p "Are you sure to restore $BACKUP_DIR? It will ERASE the actual data. [y/n] " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Operation aborted."
  exit 1
fi

SRC_DIR=data/backups/to_restore
mkdir -p $SRC_DIR
rm -rf $SRC_DIR/*
cp -R $BACKUP_DIR/* $SRC_DIR

docker exec components restore-backup.sh
