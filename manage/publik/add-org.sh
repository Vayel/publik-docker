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
export FROM_EMAIL='$FROM_EMAIL'
export EMAIL_SENDER_NAME='$EMAIL_SENDER_NAME'
export EMAIL_SUBJECT_PREFIX='$EMAIL_SUBJECT_PREFIX'
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
    --from-email)
      FROM_EMAIL="$2"
      shift # past argument
      shift # past value
    ;;
    --email-sender)
      EMAIL_SENDER_NAME="$2"
      shift # past argument
      shift # past value
    ;;
    --email-subject-prefix)
      EMAIL_SUBJECT_PREFIX="$2"
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
  echo_error "Illegal number of arguments"
  echo "Help: ./add-org.sh SLUG TITLE [--theme <folder_in_data/themes/themes>] [--url <url>] [--phone <phone>] \ "
  echo "                   [--email <email> [--addr <text>] [--addr2 <text>] [--postcode <text>] \ "
  echo "                   [--position 'lat;lng'] [--template <folder_in_data/site-templates>] \ "
  echo "                   [--from-email <email>] [--email-sender <name>] \ "
  echo "                   [--email-subject-prefix <text>] \ "
  echo "                   [--noinput]"
  echo
  echo "Notes:"
  echo "  * If --theme or --template is not specified, interactive selection is asked"
  echo
  echo "Examples:"
  echo '  ./manage/publik/add-org.sh lyon Lyon'
  echo '  ./manage/publik/add-org.sh mon-village "Mon village" \ '
  echo '      --url https://site-officiel-de-mon-village.fr \ '
  echo '      --phone "01 23 45 67 89" \'
  echo '      --email contact@mon-village.fr \ '
  echo '      --addr "2 rue XXX" \ '
  echo '      --addr2 "Espace coworking" \ '
  echo '      --postcode 12120 \ '
  echo '      --from-email repasrepondre@mon-publik.fr \ '
  echo '      --email-sender "John Doe"  \ '
  echo '      --email-subject-prefix "Publik"  \ '
  echo '      --position "44.1833;2.66667"'
  exit 1
fi

export SLUG=$1
export TITLE="$2"

BASE_DIR=`pwd`
DIR="$BASE_DIR/data/sites/$SLUG"
BASE_TEMPLATE_DIR="$BASE_DIR/site-template"
TEMPLATES_DIR="$BASE_DIR/data/site-templates"
THEMES_DIR="$BASE_DIR/data/themes/themes"

if [ -d "$DIR" ]; then
  echo_error "$DIR already exists, please remove it"
  exit 1
fi

if [ ! -d "$TEMPLATES_DIR" ]; then
  echo_warning "$TEMPLATES_DIR/ does not exist. Creating it from $BASE_TEMPLATE_DIR"
  mkdir -p $TEMPLATES_DIR
  cp -R $BASE_TEMPLATE_DIR/* $TEMPLATES_DIR/
fi

for varname in SITE_URL PHONE EMAIL ADDR ADDR2 POSTCODE TOWN LATITUDE LONGITUDE
do
  if [ -v $varname ];
  then
    val=${!varname}
  fi
  if [ -z "$val" ]; then
    read -p "$varname: "
    eval "$varname"="'$REPLY'"
  fi
done

if [ ! -z "$LATITUDE" ] && [ ! -z "$LONGITUDE" ];
then
  DEFAULT_POSITION="$LATITUDE;$LONGITUDE"
fi

if [ -z "$THEME" ]; then
  if [ ! -d "$THEMES_DIR" ] || $NOINPUT; then
    THEME=publik
  else
    echo_error "No theme supplied."
    PS3="Choose theme: "
    select theme in publik $(ls $THEMES_DIR | grep -v "^__"); do
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
  if $NOINPUT; then
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
for VAR in SLUG TITLE THEME SITE_URL PHONE EMAIL ADDR ADDR2 POSTCODE DEFAULT_POSITION TEMPLATE FROM_EMAIL EMAIL_SENDER_NAME EMAIL_SUBJECT_PREFIX
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

SUBST_STR='$SLUG $TITLE $THEME $SITE_URL $PHONE $EMAIL $ADDR $ADDR2 $POSTCODE $FROM_EMAIL $EMAIL_SENDER_NAME $EMAIL_SUBJECT_PREFIX'

./manage/subst-env.sh "$DIR/hobo-recipe.json.template" "$DIR/hobo-recipe.json.template" "$SUBST_STR"
./manage/subst-env.sh "$DIR/hobo-recipe.json.template" "$DIR/hobo-recipe.json"

for prefix in user agent
do
  if [ -f "$DIR/$prefix-portal.json.template" ]; then
    ./manage/subst-env.sh "$DIR/$prefix-portal.json.template" "$DIR/$prefix-portal.json.template" "$SUBST_STR"
    ./manage/subst-env.sh "$DIR/$prefix-portal.json.template" "$DIR/$prefix-portal.json"
    rm "$DIR/$prefix-portal.json.template"
  fi
done
