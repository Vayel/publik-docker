#!/bin/bash
# Usage:
# build-wcs-template.sh <my/dir/my-template.zip> [<my-org-slug>]


CONF_FOLDER=/tmp/sites
DEST_DIR=/tmp/sites/_build
OUTPUT_FILE=$1
TEMPLATE_NAME=main.zip
URL_PREFIX=

if [ "$#" -ne 1 ]; then
  ORG=$2
  URL_PREFIX="$ORG."
  TEMPLATE_NAME="$ORG.zip"
  CONF_FOLDER="/tmp/sites/$ORG/_build"
fi

mkdir -p $DEST_DIR

echo "Importing wcs config from $CONF_FOLDER/..."
if [ -f "$CONF_FOLDER/wcs-env.sh" ]; then
  . "$CONF_FOLDER/wcs-env.sh"
else
  export WCS_FROM_EMAIL="$ADMIN_MAIL_ADDR"
  export WCS_REPLY_TO_EMAIL="$ADMIN_MAIL_ADDR"
fi

export URL_PREFIX

# Need to inject variables to both basic config and site-specific config
subst.sh /tmp/wcs-config.json.template "$DEST_DIR/config.json"
subst.sh "$DEST_DIR/config.json" "$DEST_DIR/config.json" '$URL_PREFIX $DEFAULT_POSITION $WCS_FROM_EMAIL $WCS_REPLY_TO_EMAIL'

# Need to inject variables to both basic config and site-specific config
subst.sh /tmp/wcs-site-options.cfg.template "$DEST_DIR/site-options.cfg"
subst.sh "$DEST_DIR/site-options.cfg" "$DEST_DIR/site-options.cfg" '$URL_PREFIX $DEFAULT_POSITION $WCS_FROM_EMAIL $WCS_REPLY_TO_EMAIL'

zip -j "$OUTPUT_FILE" "$DEST_DIR/"*
# We need the config file in the skeletons folder to deploy wcs
cp "$OUTPUT_FILE" "/var/lib/wcs/skeletons/$TEMPLATE_NAME"
