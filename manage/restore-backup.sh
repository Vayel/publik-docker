#!/bin/bash

BACKUP_DIR=$1

if [ -z "$BACKUP_DIR" ]; then
  echo "Usage: restore-backup.sh <path>"
  exit 1
fi

read -p "Are you sure to restore ${BACKUP_DIR}? It will ERASE the actual data. [y/n] " -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo "Operation aborted."
  exit 1
fi

echo "TODO"
