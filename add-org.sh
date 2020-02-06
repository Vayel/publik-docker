#!/bin/bash

set -eu

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters"
  echo 'Help: ./add-org.sh my-organization "My organization"'
  exit 1
fi

export SLUG=$1
export TITLE="$2"
export THEME=publik # TODO: read arg but make sure in cook.sh that the theme is installed before deploying
DIR="data/sites/$SLUG"

echo "Creating $DIR..."
echo "Slug: $SLUG"
echo "Title: $TITLE"
echo "Theme: $THEME"

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
echo "Please edit $DEST"
