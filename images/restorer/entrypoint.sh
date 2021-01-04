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

# wcs creates tables in admin db but we cannot drop the admin db so we need to
# delete the tables manually
PGPASSWORD="$PASS_POSTGRES" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" --quiet -c "DROP OWNED BY wcs;"

cd $SRC_DIR
for fname in *.sql; do
  PGPASSWORD="$PASS_POSTGRES" psql -f "$fname" -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" --quiet
done

echo
echo "Backup successfully restored!"
