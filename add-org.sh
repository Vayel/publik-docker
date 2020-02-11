#!/bin/bash

set -eu

export THEME='$ORG_DEFAULT_THEME'
CREATE_THEME=false
export DEFAULT_POSITION="48.866667;2.333333"
export SITE_URL=
export PHONE=
export EMAIL=
export ADDR=
export ADDR2=
export POSTCODE=
export TOWN=

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
    --phone)
      PHONE="$2"
      shift # past argument
      shift # past value
    ;;
    --email)
      EMAIL="$2"
      shift # past argument
      shift # past value
    ;;
    --addr)
      ADDR="$2"
      shift # past argument
      shift # past value
    ;;
    --addr2)
      ADDR2="$2"
      shift # past argument
      shift # past value
    ;;
    --postcode)
      POSTCODE="$2"
      shift # past argument
      shift # past value
    ;;
    --position)
      DEFAULT_POSITION="$2"
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
  echo "Help: ./add-org.sh SLUG TITLE [--theme THEME] [--url URL] [--phone PHONE] \ "
  echo "                   [--email EMAIL] [--addr ADDR] [--addr2 ADDR2] [--postcode POSTCODE] \ "
  echo "                   [--position 'lat;lng']"
  echo "Examples:"
  echo '  ./add-org.sh lyon Lyon'
  echo '  ./add-org.sh mon-village "Mon village" --theme mon-village --url https://mon-village.fr \ '
  echo '                            --phone 0123456789 --email a@b.c --addr "2 rue XXX" \ '
  echo '                            --addr2 "Espace coworking" --postcode 12120 --position "48.866667;2.333333"'
  exit 1
fi

export SLUG=$1
export TITLE="$2"
DIR="data/sites/$SLUG"
THEME_DIR="themes/$THEME"

if [ -d "$DIR" ]; then
  echo "$DIR already exists, please remove it"
  exit 1
fi

echo "Creating organization..."
for VAR in SLUG TITLE THEME SITE_URL PHONE EMAIL ADDR ADDR2 POSTCODE DEFAULT_POSITION
do
  echo "$VAR=${!VAR}"
done

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
cp -R org_template "$DIR"
DEST="$DIR/hobo-recipe.json.template"
envsubst '$SLUG $TITLE $THEME $SITE_URL $PHONE $EMAIL $ADDR $ADDR2 $POSTCODE' < org_template/hobo-recipe.json.template > "$DEST.tmp"
encoding=`file -i "$DEST.tmp" | cut -f 2 -d";" | cut -f 2 -d=`
iconv -f $encoding -t utf-8 "$DEST.tmp" > $DEST
rm "$DEST.tmp"

envsubst '$EMAIL $DEFAULT_POSITION' < org_template/wcs-env.sh.template > "$DIR/wcs-env.sh"
