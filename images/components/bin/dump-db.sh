#!/bin/bash

DEST_DIR=$1

if [ -z "$DEST_DIR" ]; then
  echo "Usage: dump-db.sh <dest_dir>"
  exit 1
fi

for db in authentic2_multitenant combo fargo hobo passerelle wcs; do
  PGPASSWORD="$PASS_POSTGRES" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" $db --clean --create --if-exists > "$DEST_DIR/$db.sql"
done
