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
export TEMPLATE=
export MAIN_COLOR="#0e6ba4"

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
    --template)
      TEMPLATE="$2"
      shift # past argument
      shift # past value
    ;;
    --main-color)
      MAIN_COLOR="$2"
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
  echo "                   [--position 'lat;lng'] [--template TEMPLATE] [--main-color MAIN_COLOR]"
  echo "Notes:"
  echo "  * If --theme is not specified, the default theme data/config.env:ORG_DEFAULT_THEME is used"
  echo "  * TEMPLATE refers to folders in org-templates/"
  echo "Examples:"
  echo '  ./add-org.sh lyon Lyon default'
  echo '  ./add-org.sh mon-village "Mon village" mon-template \ '
  echo '      --theme mon-village \'
  echo '      --url https://mon-village.fr \ '
  echo '      --phone 0123456789 \'
  echo '      --email a@b.c \ '
  echo '      --addr "2 rue XXX" \ '
  echo '      --addr2 "Espace coworking" \ '
  echo '      --postcode 12120 \ '
  echo '      --position "48.866667;2.333333"'
  echo '      --template mon-modele-de-commune'
  echo '      --main-color "#0e6ba4"'
  exit 1
fi

export SLUG=$1
export TITLE="$2"
DIR="data/sites/$SLUG"
THEME_DIR="themes/$THEME"
TEMPLATES_DIR="org-templates"
TEMPLATE_DIR="$TEMPLATES_DIR/$TEMPLATE"

if [ -d "$DIR" ]; then
  echo "$DIR already exists, please remove it"
  exit 1
fi

mkdir -p "$DIR"

echo "Creating organization..."
for VAR in SLUG TITLE THEME SITE_URL PHONE EMAIL ADDR ADDR2 POSTCODE DEFAULT_POSITION TEMPLATE MAIN_COLOR
do
  echo "$VAR=${!VAR}"
done

if [ "$CREATE_THEME" == "false" ]; then
  echo "Using default theme"
elif [ -d "$THEME_DIR" ]; then
  echo "Using existing theme $THEME_DIR"
else
  cd themes
  ./add-theme.sh $SLUG "$TITLE"
  cd ..
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
envsubst '$SLUG $TITLE $THEME $SITE_URL $PHONE $EMAIL $ADDR $ADDR2 $POSTCODE $MAIN_COLOR' < "$TEMPLATES_DIR/hobo-recipe.json.template" > "$DEST.tmp"
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
