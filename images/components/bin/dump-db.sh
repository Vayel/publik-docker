#!/bin/bash

DEST_DIR=$1

if [ -z "$DEST_DIR" ]; then
  echo "Usage: dump-db.sh <dest_dir>"
  exit 1
fi

PGPASSWORD="$PASS_POSTGRES" pg_dumpall -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" | gzip > "$DEST_DIR/db_dump.gz"
