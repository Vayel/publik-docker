#!/bin/bash

. colors.sh

# Fail on errors
set -eu

BASE_CONF_DIR=/etc/nginx/base_conf
CONF_DIR=/etc/nginx/conf.d

if [ ! -f "$CONF_DIR/http.conf" ];
then
  cp "$BASE_CONF_DIR/http.conf" "$CONF_DIR/http.conf"
fi

if [ ! -f "$CONF_DIR/rabbitmq.conf" ];
then
  envsubst '$ENV $DOMAIN $RABBITMQ_MANAGEMENT_PORT' < "$BASE_CONF_DIR/rabbitmq.template" \
    > "$CONF_DIR/rabbitmq.conf"
fi

if [ ! -z "$PGADMIN_PORT" ] && [ ! -f "$CONF_DIR/pgadmin.conf" ];
then
  envsubst '${ENV} ${DOMAIN} $PGADMIN_PORT' < "$BASE_CONF_DIR/pgadmin.template" \
	  > "$CONF_DIR/pgadmin.conf"
fi

if [ ! -z "$MAILCATCHER_HTTP_PORT" ] && [ -f "$CONF_DIR/mailcatcher.conf" ];
then
  envsubst '${ENV} ${DOMAIN} $MAILCATCHER_HTTP_PORT' < "$BASE_CONF_DIR/mailcatcher.template" \
	  > "$CONF_DIR/mailcatcher.conf"
fi

generate-conf.sh "$@"
generate-certificates.sh "$@"
service nginx reload
echo_success 'Proxy configuration generated!'
