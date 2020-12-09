#!/bin/bash

set -eu

. colors.sh

function copy_dir() {
  SRC=$1
  DEST=$2

  rm -rf $DEST
  mkdir -p $DEST
  cp -R $SRC/* $DEST
}

DEST_DIR=/usr/share/publik/themes/publik-base

if [ $# -eq 0 ]; then
  BASE_DIR=/tmp/themes
else
  BASE_DIR=$1
fi

if [ ! -d "$BASE_DIR" ] || [ -z "$(ls -A $BASE_DIR)" ]; then
  echo_warning "$BASE_DIR is empty, no themes to build."
  exit
fi

compile-themes.sh $BASE_DIR

mkdir -p "$DEST_DIR/templates/variants"

cd $BASE_DIR/themes
for theme in *
do
  echo "Deploying $theme..."
  copy_dir "$BASE_DIR/themes/$theme/static" "$DEST_DIR/static/$theme"
  copy_dir "$BASE_DIR/themes/$theme/templates" "$DEST_DIR/templates/variants/$theme"
done

cp "$BASE_DIR/themes.json" "$DEST_DIR/themes.json"

echo_success "Themes deployed."
