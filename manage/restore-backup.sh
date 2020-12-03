#!/bin/bash

BACKUP_DIR=$1

if [ -z "$BACKUP_DIR" ]; then
  echo "Usage: restore-backup.sh <path>"
  exit 1
fi

echo "Making a backup first..."
./manage/backup.sh

echo
echo "Restoring /var/lib data..."
echo "TODO"

echo
echo "Restoring database..."
echo "TODO"
