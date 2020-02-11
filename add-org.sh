#!/bin/bash

set -eu

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters"
  echo 'Help: ./add-org.sh my-organization "My organization"'
  exit 1
fi

export SLUG=$1
export TITLE="$2"
DIR="data/sites/$SLUG"
THEME_DIR="themes/$SLUG"

echo "Creating $TITLE (slug: $SLUG)..."

if [ -d "$THEME_DIR" ]; then
  echo "Using existing theme $THEME_DIR"
else
  echo "Creating theme in $THEME_DIR..."
  mkdir -p $THEME_DIR
  cp -R themes/publik-base/* $THEME_DIR
  sed -i "s/Publik/$TITLE/g" "$THEME_DIR/desc.xml"
  sed -i "s/publik-base/$SLUG/g" "$THEME_DIR/desc.xml"
  sed -i "s/publik/$SLUG/g" "$THEME_DIR/themes.json"
  sed -i "s/Publik/$TITLE/g" "$THEME_DIR/themes.json"
  mv "$THEME_DIR/static/publik" "$THEME_DIR/static/$SLUG"
fi

echo "Creating config files in $DIR..."
mkdir -p $DIR
DEST="$DIR/hobo-recipe.json.template"
envsubst '$SLUG $TITLE $THEME' < hobo-recipe.json.template > "$DEST.tmp"
encoding=`file -i "$DEST.tmp" | cut -f 2 -d";" | cut -f 2 -d=`
iconv -f $encoding -t utf-8 "$DEST.tmp" > $DEST
rm "$DEST.tmp"

DEST="$DIR/wcs-env.sh"
if [ ! -f "$DEST" ]; then
  cp wcs-env.sh $DEST
fi

echo "Please edit:"
echo "* Config: $DEST"
echo "* Theme: $THEME_DIR"
