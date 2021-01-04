#!/bin/bash

DEST_DIR=$1

if [ -z "$DEST_DIR" ]; then
  echo "Usage: dump-db.sh <dest_dir>"
  exit 1
fi

# We need to remove drop instructions concerning the admin
PGPASSWORD="$PASS_POSTGRES" pg_dumpall -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" --clean | grep --invert-match "DROP ROLE $DB_ADMIN_USER" | grep --invert-match "CREATE ROLE $DB_ADMIN_USER" | gzip > "$DEST_DIR/db_dump.gz"
