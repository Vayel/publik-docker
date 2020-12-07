#!/bin/bash

DEST_DIR=/tmp/backup
mkdir -p $DEST_DIR
rm -rf "$DEST_DIR/*"

echo "Saving component data from /var/lib..."
dump-var-lib.sh "$DEST_DIR"

echo "Saving database..."
dump-db.sh "$DEST_DIR"
