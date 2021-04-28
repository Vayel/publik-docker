#!/bin/bash

set -eu

. ./manage/load-env.sh
. ./manage/colors.sh

if [ "$#" -ne 2 ]; then
  echo_error "Illegal number of arguments"
  echo "Help: ./generate-saml-conf.sh SLUG TITLE"
  echo
  echo "Examples:"
  echo '  ./manage/publik/generate-saml-conf.sh lyon Lyon'
  exit 1
fi

ORG_SLUG=$1
ORG_NAME=$2

function generate_saml() {
  COMP_SUBDOMAIN=$1
  URL="https://$ORG_SLUG.$COMP_SUBDOMAIN.$DOMAIN/accounts/mellon/metadata/"
  if [ "$COMP_SUBDOMAIN" == "$WCS_SUBDOMAIN" ]; then
    URL="https://$ORG_SLUG.$WCS_SUBDOMAIN.$DOMAIN/saml/metadata"
  fi
  echo
  echo "Nom : $COMP_SUBDOMAIN | $ORG_NAME"
  echo "Raccourci : $ORG_SLUG-$COMP_SUBDOMAIN"
  echo "URL des métadonnées : $URL"
  echo "Collectivité : $ORG_NAME"
}

echo "Go to: https://${AUTHENTIC_SUBDOMAIN}.${DOMAIN}/admin/saml/libertyprovider/"
echo 'Then, click on "Ajouter depuis une URL" on top-right with the following settings:'

echo
echo "Nom : Hobo | $ORG_NAME"
echo "Raccourci : $ORG_SLUG-hobo"
echo "URL des métadonnées : https://$ORG_SLUG.$HOBO_SUBDOMAIN.$DOMAIN/accounts/mellon/metadata/"
echo "Collectivité : Collectivité par défaut"

generate_saml $COMBO_SUBDOMAIN
generate_saml $COMBO_ADMIN_SUBDOMAIN
generate_saml $WCS_SUBDOMAIN
generate_saml $PASSERELLE_SUBDOMAIN
generate_saml $FARGO_SUBDOMAIN
generate_saml $CHRONO_SUBDOMAIN
