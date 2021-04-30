#!/bin/bash

. colors.sh

function create() {
  USER=$1
  PASS=$2
  DB=$3
  # We stop on error 
  PGPASSWORD="$PASS_POSTGRES" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" -v ON_ERROR_STOP=1 --no-password <<-EOSQL
      CREATE USER "$USER";
      CREATE DATABASE "$DB" TEMPLATE=template0 LC_COLLATE='fr_FR.UTF_8' LC_CTYPE='fr_FR.UTF-8';
      GRANT ALL PRIVILEGES ON DATABASE "$DB" TO "$USER";
      ALTER USER "$USER" WITH PASSWORD '${PASS}';
EOSQL
}

# Create all databases except WCS one which is created when first started
#
# Users and databases names are defined in "images/components/*.settings.py"
create $USER_DB_AUTHENTIC $PASS_DB_AUTHENTIC $DB_AUTHENTIC
create $USER_DB_CHRONO $PASS_DB_CHRONO $DB_CHRONO
create $USER_DB_COMBO $PASS_DB_COMBO $DB_COMBO
create $USER_DB_FARGO $PASS_DB_FARGO $DB_FARGO
create $USER_DB_HOBO $PASS_DB_HOBO $DB_HOBO
create $USER_DB_PASSERELLE $PASS_DB_PASSERELLE $DB_PASSERELLE

PGPASSWORD="$PASS_POSTGRES" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" -v ON_ERROR_STOP=1 --no-password <<-EOSQL
    CREATE USER "$USER_DB_WCS" CREATEDB;
    ALTER USER "$USER_DB_WCS" WITH PASSWORD '${PASS_DB_WCS}';

    \c "$DB_COMBO";
    CREATE EXTENSION unaccent;
    \c "$DB_AUTHENTIC";
    CREATE EXTENSION unaccent;
    CREATE EXTENSION pg_trgm;
    \c "$DB_CHRONO";
    CREATE EXTENSION btree_gist;
EOSQL

# Ignore SQL errors
exit 0
