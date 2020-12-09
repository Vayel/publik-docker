#!/bin/bash

set -eu

. ./manage/colors.sh

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
NOINPUT=false

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
    --noinput)
      NOINPUT=true
      shift # past argument
    ;;
    *)
      POSITIONAL+=("$1")
      shift # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$#" -ne 2 ]; then
  echo_error "Illegal number of parameters"
  echo "Help: ./add-org.sh SLUG TITLE [--theme THEME] [--url URL] [--phone PHONE] \ "
  echo "                   [--email EMAIL] [--addr ADDR] [--addr2 ADDR2] [--postcode POSTCODE] \ "
  echo "                   [--position 'lat;lng'] [--template TEMPLATE] \ "
  echo "                   [--bgcolor BACKGROUND_COLOR] [--textcolor TEXT_COLOR] \ "
  echo "                   [--noinput]"
  echo
  echo "Notes:"
  echo "  * If --theme is not specified, the default theme data/config.env:ORG_DEFAULT_THEME is used"
  echo "  * TEMPLATE refers to folders in org-templates/"
  echo
  echo "Examples:"
  echo '  ./add-org.sh lyon Lyon'
  echo '  ./add-org.sh mon-village "Mon village" \ '
  echo '      --theme smica \'
  echo '      --template mairie-defaut \ '
  echo '      --url https://site-officiel-de-mon-village.fr \ '
  echo '      --phone 0123456789 \'
  echo '      --email contact@mon-village.fr \ '
  echo '      --addr "2 rue XXX" \ '
  echo '      --addr2 "Espace coworking" \ '
  echo '      --postcode 12120 \ '
  echo '      --position "48.866667;2.333333" \ '
  echo '      --bgcolor "#0e6ba4" \ '
  echo '      --textcolor "#FFFFFF"'
  exit 1
fi

export SLUG=$1
export TITLE="$2"

BASE_DIR=`pwd`
DIR="$BASE_DIR/data/sites/$SLUG"
TEMPLATES_DIR="$BASE_DIR/org-templates"
THEMES_DIR="$BASE_DIR/data/themes/themes"

if [ -d "$DIR" ]; then
  echo_error "$DIR already exists, please remove it"
  exit 1
fi

if [ -z "$THEME" ]; then
  if [ ! -d "$THEMES_DIR" ] || $NOINPUT; then
    THEME=publik
  else
    echo_error "No theme supplied."
    PS3="Choose theme: "
    select theme in publik $(ls $THEMES_DIR); do
      if [ -z "$REPLY" ] || [ -z "$theme" ]; then
        echo "Please select a valid theme number."
      elif [ "$theme" == "publik" ] || [ -d "$THEMES_DIR/$theme" ]; then
        THEME=$theme
        break
      else
        echo "Unexisting theme $THEMES_DIR/$theme"
      fi
    done
  fi
fi

if [ -z "$TEMPLATE" ]; then
  if [ ! -d "$TEMPLATES_DIR" ] || $NOINPUT; then
    TEMPLATE=""
  else
    echo_error "No templates supplied."
    cd $TEMPLATES_DIR
    PS3="Choose template: "
    select template in "" $(ls -d */); do
      if [ -z "$REPLY" ]; then
        echo "Please select a valid theme number."
      elif [ -z "$template" ]; then
        TEMPLATE=""
        break
      elif [ -d "$TEMPLATES_DIR/$template" ]; then
        TEMPLATE=$(echo $template | rev | cut -c 2- | rev)
        break
      else
        echo "Unexisting template $TEMPLATES_DIR/$template"
      fi
    done
  fi
fi

cd $BASE_DIR
TEMPLATE_DIR="$TEMPLATES_DIR/$TEMPLATE"
mkdir -p "$DIR"

echo "Creating organization..."
for VAR in SLUG TITLE THEME SITE_URL PHONE EMAIL ADDR ADDR2 POSTCODE DEFAULT_POSITION TEMPLATE BACKGROUND_COLOR TEXT_COLOR
do
  echo "$VAR=${!VAR}"
done

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
