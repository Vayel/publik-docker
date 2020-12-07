#!/bin/bash

SRC_DIR=$1
# We use an internal temporary directory to avoid decompressing the data
# in the mounted dir, which is very slow
TMP_DIR=/tmp/backup_to_restore_tmp

if [ -z "$SRC_DIR" ]; then
  echo "Usage: restore-backup.sh <src_dir>"
  exit 1
fi

echo
echo "Restoring /var/lib data..."
cd "$SRC_DIR"
mv var_lib.tar "$TMP_DIR"
cd "$TMP_DIR"
tar -xf var_lib.tar
for dirname in authentic2-multitenant combo fargo hobo passerelle wcs
do
  dest="/var/lib/$dirname"
  rm -rf $dest
  mv $dirname $dest
done

echo
echo "Restoring database..."
cd "$SRC_DIR"
echo "TODO"

rm -rf $TMP_DIR
