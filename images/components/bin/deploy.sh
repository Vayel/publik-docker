#!/bin/bash

. colors.sh

HOBO_VERBOSITY=2

echo
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
  echo_error "Cannot find hobo recipe $TEMPL_PATH"
  echo
  exit 1
fi
subst.sh $TEMPL_PATH $RECIPE_PATH

echo
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
      echo_error "Component not ready and there are no more attempts left!"
      echo
      exit 1
    else
      echo_warning "Component not ready yet. Trying again in 10 seconds..."
      echo
      let attempt_num++
	    sleep 10
    fi
  done
}

function find_ip {
  ping -c 2 $1 | head -2 | tail -1 | awk '{print $5}' | sed 's/[(:)]//g'
}

function testHttpCode {
  domain=$1
  port=$2
  component=$3
  http_code=$4
  t=`wget --spider --max-redirect 0 -S https://$domain:$port 2>&1 | grep "HTTP/" | awk '{print $2}'`
  first_digit="$(echo $t | head -c 1)"
  if [ "$t" == "$http_code" ]; then
    echo_success "OK: $component returned the expected $http_code http code on $domain:$port"
    return 0
  fi
  if [ -z "$t" ]; then
    ip=`find_ip $domain`
    echo_error "ERROR: $component is unreachable on $domain ($ip)"
    return 1
  fi
  if [ "$first_digit" == "4" ] || [ "$first_digit" == "5" ]; then
    echo_error "ERROR: $component returned http error code $t instead of expected $http_code on $domain"
    return 1
  fi
  if [ "$t" != "$http_code" ]; then
    echo_warning "WARNING: $component returned http code $t instead of expected $http_code on $domain"
    return 0
  fi
}

function testHttpContains {
  domain=$1
  port=$2
  component=$3
  content=$4
  t=`wget -O - https://$domain:$port 2>&1 | grep $content | wc -l`
  if [ $t -eq 0 ]
  then
    ip=`find_ip $domain`
    echo_error "ERROR: $component html does not contain $content on $domain ($ip)"
    return 1
  fi
  echo_success "OK: $component returned a html containing $content on $domain"
}

# Before cook, wait for all services to be ready
echo
echo "###"
echo "### Checking components..."
echo "###"
retry 300 testHttpCode ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} combo 404
retry 300 testHttpCode ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} combo_agent 404
retry 300 testHttpCode ${URL_PREFIX}${CHRONO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} chrono 404
retry 300 testHttpCode ${URL_PREFIX}${PASSERELLE_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} passerelle 404
retry 300 testHttpCode ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} wcs 404
retry 300 testHttpCode ${URL_PREFIX}${AUTHENTIC_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} authentic 404
retry 300 testHttpCode ${URL_PREFIX}${FARGO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} fargo 404
retry 300 testHttpCode ${URL_PREFIX}${HOBO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} hobo 404

echo
echo "###"
echo "### Deploying components..."
echo "###"
function cook {
  echo "*** Deploying $1"
  # Execute cook in hobo (Many time as recommended by Entr'ouvert)
  sudo -u hobo hobo-manage cook $1 -v ${HOBO_VERBOSITY} --timeout=${HOBO_DEPLOY_TIMEOUT} --traceback
  sudo -u hobo hobo-manage cook $1 -v ${HOBO_VERBOSITY} --timeout=${HOBO_DEPLOY_TIMEOUT} --traceback
  sudo -u hobo hobo-manage cook $1 -v ${HOBO_VERBOSITY} --timeout=${HOBO_DEPLOY_TIMEOUT} --traceback
}

cook $RECIPE_PATH

echo
echo "###"
echo "### Importing site data..."
echo "###"
import-site.sh $ORG

# Test all services
set -e
echo
echo "###"
echo "### Checking deployment..."
echo "###"
COMBO_OK="Combo fonctionne"
AUTHENTIC_OK="Connexion"
testHttpContains ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} combo $COMBO_OK
testHttpContains ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} combo_agent $COMBO_OK
testHttpContains ${URL_PREFIX}${CHRONO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} chrono $AUTHENTIC_OK
testHttpContains ${URL_PREFIX}${PASSERELLE_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} passerelle $AUTHENTIC_OK
testHttpContains ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} wcs $AUTHENTIC_OK
testHttpContains ${URL_PREFIX}${FARGO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} fargo $AUTHENTIC_OK
testHttpContains ${URL_PREFIX}${HOBO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} hobo $AUTHENTIC_OK

# Do not check authentic for organizations
if [ -z "$ORG" ]; then
  testHttpContains ${URL_PREFIX}${AUTHENTIC_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} authentic $COMBO_OK
  testHttpCode ${URL_PREFIX}${AUTHENTIC_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} authentic 302
fi

testHttpCode ${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} combo 200
testHttpCode ${URL_PREFIX}${COMBO_ADMIN_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} combo_agent 200
testHttpCode ${URL_PREFIX}${CHRONO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} chrono 302
testHttpCode ${URL_PREFIX}${PASSERELLE_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} passerelle 302
testHttpCode ${URL_PREFIX}${WCS_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} wcs 302
testHttpCode ${URL_PREFIX}${FARGO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} fargo 302
testHttpCode ${URL_PREFIX}${HOBO_SUBDOMAIN}${ENV}.${DOMAIN} ${HTTPS_PORT} hobo 302

echo
echo_success "Configuration OK (Hobo cook)"
echo
echo "Go to https://${URL_PREFIX}${COMBO_SUBDOMAIN}${ENV}.${DOMAIN}:${HTTPS_PORT}"
