#!/bin/bash

. colors.sh

# Fail on errors
set -eu

stop-services.sh

SRC_DIR=/tmp/backup_to_restore

for comp in authentic2-multitenant combo chrono fargo hobo passerelle
do
  dest="/var/lib/$comp/tenants"
  echo "Restoring $dest"
  cd $dest
  rm -rf *
  tar -xf "$SRC_DIR/var_lib_${comp}_tenants.tar" --strip-components=1
done

cd /var/lib/wcs
echo "Restoring $(pwd)"
rm -rf *
tar -xf "$SRC_DIR/var_lib_wcs.tar" --strip-components=1

set-var-lib-ownership.sh

echo
echo "Restoring database..."

cd $SRC_DIR
for fname in *.sql; do
  echo "Running $fname"
  PGPASSWORD="$PASS_POSTGRES" psql -v ON_ERROR_STOP=ON -f "$fname" -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER"
done

echo
echo_success "Backup successfully restored!"
echo

start-services.sh
