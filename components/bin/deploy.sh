#!/bin/bash

echo "###"
echo "### Creating hobo recipe..."
echo "###"
TEMPL_PATH=/tmp/hobo-recipe.json.template
RECIPE_PATH=/tmp/hobo-recipe.json
ORG=
URL_PREFIX=

if [ "$#" -ne 0 ] && [ ! -z "$1" ]; then
  ORG=$1
  URL_PREFIX="$ORG."
  TEMPL_PATH="/tmp/sites/$ORG/hobo-recipe.json.template"
  RECIPE_PATH="/tmp/sites/$ORG/_build/hobo-recipe.json"
  mkdir -p "/tmp/sites/$ORG/_build"
fi

if [ ! -f $TEMPL_PATH ]; then
  echo "Cannot find hobo recipe $TEMPL_PATH"
  exit 1
fi
subst.sh $TEMPL_PATH $RECIPE_PATH

echo "###"
echo "### Configuring nginx..."
echo "###"
config-nginx.sh $ORG
service nginx reload

function retry() {
  local -r -i max_attempts="$1"; shift
  local -r cmd="$@"
  local -i attempt_num=1

  until $cmd
  do
    if (( attempt_num == max_attempts ))
    then
      echo "Component not ready and there are no more attempts left!"
      exit 1
    else
      echo "Component not ready yet. Trying again in 10 seconds..."
      let attempt_num++
	    sleep 10
    fi
  done
}

function testHttpCode {
  t=`wget --spider --max-redirect 0 -S https://$1 2>&1 | grep "HTTP/" | awk '{print $2}'`
  if [ "$t" != "$3" ]
  then
    echo "ERROR: $2 returned http code $t instead of expected $3"
    return 1
  fi
  echo "OK: $2 returned the expected $3 http code"
}

function testHttpContains {
  t=`wget -O - https://$1 2>&1 | grep $3 | wc -l`
  if [ $t -eq 0 ]
  then
    echo "ERROR: $2 html does not contain $3"
    return 1
  fi
  echo "OK: $2 returned a html containing $3"
}

# Before cook, wait for all services to be ready
echo "###"
echo "### Checking components..."
echo "###"
retry 300 testHttpCode ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} combo 404
retry 300 testHttpCode ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} combo_agent 404
retry 300 testHttpCode ${URL_PREFIX}${PASSERELLE_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} passerelle 404
retry 300 testHttpCode ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} wcs 404
retry 300 testHttpCode ${URL_PREFIX}${AUTHENTIC_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} authentic 404
retry 300 testHttpCode ${URL_PREFIX}${FARGO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} fargo 404
retry 300 testHttpCode ${URL_PREFIX}${HOBO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} hobo 404

echo "###"
echo "### Deploying components..."
echo "###"
function cook {
  echo "*** Deploying $1"
  # Execute cook in hobo (Many time as recommended by Entr'ouvert)
  sudo -u hobo hobo-manage cook $1 -v ${HOBO_DEPLOY_VERBOSITY} --timeout=${HOBO_DEPLOY_TIMEOUT}
  sudo -u hobo hobo-manage cook $1 -v ${HOBO_DEPLOY_VERBOSITY} --timeout=${HOBO_DEPLOY_TIMEOUT}
  sudo -u hobo hobo-manage cook $1 -v ${HOBO_DEPLOY_VERBOSITY} --timeout=${HOBO_DEPLOY_TIMEOUT}
}

cook $RECIPE_PATH

# After cook, test all services
set -e
echo "###"
echo "### Checking deployment..."
echo "###"
COMBO_OK="Combo fonctionne"
AUTHENTIC_OK="Connexion"
testHttpContains ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} combo $COMBO_OK
testHttpContains ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} combo_agent $COMBO_OK
testHttpContains ${URL_PREFIX}${PASSERELLE_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} passerelle $AUTHENTIC_OK
testHttpContains ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} wcs $AUTHENTIC_OK
testHttpContains ${URL_PREFIX}${FARGO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} fargo $AUTHENTIC_OK
testHttpContains ${URL_PREFIX}${HOBO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} hobo $AUTHENTIC_OK

# Do not check authentic for organizations
if [ -z "$ORG" ]; then
  testHttpContains ${URL_PREFIX}${AUTHENTIC_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} authentic $COMBO_OK
  testHttpCode ${URL_PREFIX}${AUTHENTIC_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} authentic 302
fi

testHttpCode ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} combo 200
testHttpCode ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} combo_agent 200
testHttpCode ${URL_PREFIX}${PASSERELLE_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} passerelle 302
testHttpCode ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} wcs 200
testHttpCode ${URL_PREFIX}${FARGO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} fargo 302
testHttpCode ${URL_PREFIX}${HOBO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT} hobo 302

echo "###"
echo "### Importing site data..."
echo "###"
import-site.sh $ORG

echo "###"
echo "### Configuration OK (Hobo cook)"
echo "###"
