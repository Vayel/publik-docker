#!/bin/bash

DEST_DIR=$1

if [ -z "$DEST_DIR" ]; then
  echo "Usage: dump-var-lib.sh <dest_dir>"
  exit 1
fi

mkdir -p $DEST_DIR
for comp in authentic2-multitenant combo fargo hobo passerelle
do
  cd "/var/lib/$comp" && tar -cf "$DEST_DIR/var_lib_${comp}_tenants.tar" tenants
done

cd /var/lib && tar -cf "$DEST_DIR/var_lib_wcs.tar" wcs
