#!/bin/bash

# Fail on errors
set -eu

SRC_DIR=/tmp/backup_to_restore

for comp in authentic2-multitenant combo fargo hobo passerelle
do
  dest="/var/lib/$comp/tenants"
  echo "Restoring $dest"
  cd $dest
  rm -rf *
  tar -xf "$SRC_DIR/var_lib_${comp}_tenants.tar" --strip-components=1
done

cd /var/lib/wcs
rm -rf *
tar -xf "$SRC_DIR/var_lib_wcs.tar" --strip-components=1

echo
echo "Restoring database..."

function dbcmd() {
  cmd=$1
  shift
  PGPASSWORD="$PASS_POSTGRES" $cmd -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" "$@"
}

dbcmd psql -d $DB_ADMIN_USER -c "DROP OWNED BY wcs CASCADE;"

# Clean instructions were added to the dump file so we don't need to do it ourselves
gunzip -c "$SRC_DIR/db_dump.gz" | dbcmd psql --set ON_ERROR_STOP=on

echo
echo "Backup successfully restored!"
