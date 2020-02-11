#!/bin/bash

set -eu

export THEME='$ORG_DEFAULT_THEME'
CREATE_THEME=false
export SITE_URL=

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --theme)
      THEME="$2"
      CREATE_THEME=true
      shift # past argument
      shift # past value
    ;;
    --url)
      SITE_URL="$2"
      shift # past argument
      shift # past value
    ;;
    *)
      POSITIONAL+=("$1")
      shift # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters"
  echo "Help: ./add-org.sh SLUG TITLE [--theme THEME] [--url URL]"
  echo "Examples:"
  echo '  ./add-org.sh lyon Lyon'
  echo '  ./add-org.sh mon-village "Mon village" --theme mon-village --url https://mon-village.fr'
  exit 1
fi

export SLUG=$1
export TITLE="$2"
DIR="data/sites/$SLUG"
THEME_DIR="themes/$THEME"

echo "Creating $TITLE (slug: $SLUG)..."

if [ "$CREATE_THEME" == "false" ]; then
  echo "Using default theme"
elif [ -d "$THEME_DIR" ]; then
  echo "Using existing theme $THEME_DIR"
else
  echo "Creating theme in $THEME_DIR..."
  mkdir -p $THEME_DIR
  cp -R themes/publik-base/* $THEME_DIR
  sed -i "s/Publik/$TITLE/g" "$THEME_DIR/desc.xml"
  sed -i "s/publik-base/$THEME/g" "$THEME_DIR/desc.xml"
  sed -i "s/publik/$THEME/g" "$THEME_DIR/themes.json"
  sed -i "s/Publik/$TITLE/g" "$THEME_DIR/themes.json"
  mv "$THEME_DIR/static/publik" "$THEME_DIR/static/$THEME"
fi

echo "Creating config files in $DIR..."
mkdir -p $DIR
DEST="$DIR/hobo-recipe.json.template"
envsubst '$SLUG $TITLE $THEME $SITE_URL' < hobo-recipe.json.template > "$DEST.tmp"
encoding=`file -i "$DEST.tmp" | cut -f 2 -d";" | cut -f 2 -d=`
iconv -f $encoding -t utf-8 "$DEST.tmp" > $DEST
rm "$DEST.tmp"

DEST="$DIR/wcs-env.sh"
if [ ! -f "$DEST" ]; then
  cp wcs-env.sh $DEST
fi

echo "Please edit:"
echo "* Config: $DEST"
if [ "$CREATE_THEME" == "true" ]; then
  echo "* Theme: $THEME_DIR"
fi
