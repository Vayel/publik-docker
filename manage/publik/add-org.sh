#!/bin/bash

set -eu

BASE_DIR=`pwd`

function get_default_theme() {
  cat $BASE_DIR/.env | grep ORG_DEFAULT_THEME | cut -c19-
}

export THEME=
export DEFAULT_POSITION="48.866667;2.333333"
export SITE_URL=
export PHONE=
export EMAIL=
export ADDR=
export ADDR2=
export POSTCODE=
export TOWN=
export TEMPLATE=
export BACKGROUND_COLOR="#0e6ba4"
export TEXT_COLOR="#FFFFFF"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --theme)
      THEME="$2"
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
    --template)
      TEMPLATE="$2"
      shift # past argument
      shift # past value
    ;;
    --bgcolor)
      BACKGROUND_COLOR="$2"
      shift # past argument
      shift # past value
    ;;
    --textcolor)
      TEXT_COLOR="$2"
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
  echo "                   [--position 'lat;lng'] [--template TEMPLATE] \ "
  echo "                   [--bgcolor BACKGROUND_COLOR] [--textcolor TEXT_COLOR]"
  echo "Notes:"
  echo "  * If --theme is not specified, the default theme data/config.env:ORG_DEFAULT_THEME is used"
  echo "  * TEMPLATE refers to folders in org-templates/"
  echo "Examples:"
  echo '  ./add-org.sh lyon Lyon'
  echo '  ./add-org.sh mon-village "Mon village" \ '
  echo '      --theme commune-defaut \'
  echo '      --url https://mon-village.fr \ '
  echo '      --phone 0123456789 \'
  echo '      --email a@b.c \ '
  echo '      --addr "2 rue XXX" \ '
  echo '      --addr2 "Espace coworking" \ '
  echo '      --postcode 12120 \ '
  echo '      --position "48.866667;2.333333" \ '
  echo '      --template mairie-defaut \ '
  echo '      --bgcolor "#0e6ba4" \ '
  echo '      --textcolor "#FFFFFF"'
  exit 1
fi

export SLUG=$1
export TITLE="$2"
DIR="data/sites/$SLUG"
TEMPLATES_DIR="org-templates"
TEMPLATE_DIR="$TEMPLATES_DIR/$TEMPLATE"

if [ -d "$DIR" ]; then
  echo "$DIR already exists, please remove it"
  exit 1
fi

if [ -z "$THEME" ]; then
  read -p "No theme supplied. Default '$(get_default_theme)' defined in .env will be used. Continue [y/n]? " -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation aborted."
    exit
  fi
fi

if [ -z "$TEMPLATE" ]; then
  read -p "No template supplied. User and agent portals won't be initialized and no categories will be imported. Continue [y/n]? " -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation aborted."
    exit
  fi
fi

mkdir -p "$DIR"

echo "Creating organization..."
for VAR in SLUG TITLE THEME SITE_URL PHONE EMAIL ADDR ADDR2 POSTCODE DEFAULT_POSITION TEMPLATE BACKGROUND_COLOR TEXT_COLOR
do
  echo "$VAR=${!VAR}"
done

if [ -z "$THEME" ]; then
  echo "Using default theme '$(get_default_theme)' defined in .env"
  THEME='$ORG_DEFAULT_THEME'
else
  echo "Using theme $THEME"
fi

echo "Creating config files in $DIR..."
if [ ! -z "$TEMPLATE" ]; then
  cp -R "$TEMPLATE_DIR"/* "$DIR"
fi

# Copy all files in $TEMPLATES_DIR that are not in $DIR
for path in "$TEMPLATES_DIR"/*
do
  if [ "$path" == "$TEMPLATES_DIR/README.md" ]; then
    continue
  fi
  if [ -f "$path" ]; then
    cp -n "$path" "$DIR"
  fi
done

DEST="$DIR/hobo-recipe.json.template"
envsubst '$SLUG $TITLE $THEME $SITE_URL $PHONE $EMAIL $ADDR $ADDR2 $POSTCODE $BACKGROUND_COLOR $TEXT_COLOR' < "$TEMPLATES_DIR/hobo-recipe.json.template" > "$DEST.tmp"
encoding=`file -i "$DEST.tmp" | cut -f 2 -d";" | cut -f 2 -d=`
iconv -f $encoding -t utf-8 "$DEST.tmp" > $DEST
rm "$DEST.tmp"

for prefix in user agent
do
  if [ -f "$DIR/$prefix-portal.json.template" ]; then
    envsubst '$SLUG $TITLE' < "$DIR/$prefix-portal.json.template" > "$DIR/$prefix-portal.json"
    rm "$DIR/$prefix-portal.json.template"
  fi
done
