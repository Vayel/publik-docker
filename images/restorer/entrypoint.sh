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
echo "TODO: db"
