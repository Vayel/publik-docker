#!/bin/bash

DEST_DIR=$1

if [ -z "$DEST_DIR" ]; then
  echo "Usage: dump-db.sh <dest_dir>"
  exit 1
fi

for db in authentic2_multitenant combo fargo hobo passerelle $DB_ADMIN_USER; do
  options="--clean --create"
  # We prevent admin db deletion as we need it for the import
  if [ "$db" == "$DB_ADMIN_USER" ]; then
    options=""
  fi
  PGPASSWORD="$PASS_POSTGRES" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" $db $options > "$DEST_DIR/$db.sql"
done
