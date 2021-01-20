#!/bin/bash

. colors.sh

count=`PGPASSWORD="$PASS_POSTGRES" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" --no-password -q -l | grep hobo | wc -l`

if [ "$count" != "0" ]; then
  echo_success "Database already configured"
  echo
  exit 0
fi

set -e

# Create all databases except WCS one which is created when first started
#
# Users and databases names are defined in "images/components/*.settings.py"
PGPASSWORD="$PASS_POSTGRES" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" -v ON_ERROR_STOP=1 --no-password <<-EOSQL
    CREATE USER hobo;
    CREATE DATABASE hobo TEMPLATE=template0 ENCODING 'UTF8' LC_COLLATE='fr_FR.UTF_8' LC_CTYPE='fr_FR.UTF-8';
    GRANT ALL PRIVILEGES ON DATABASE hobo TO hobo;
    ALTER USER hobo WITH PASSWORD '${PASS_DB_HOBO}';
    CREATE USER passerelle;
    CREATE DATABASE passerelle TEMPLATE=template0 LC_COLLATE='fr_FR.UTF_8' LC_CTYPE='fr_FR.UTF-8';
    GRANT ALL PRIVILEGES ON DATABASE passerelle TO passerelle;
    ALTER USER passerelle WITH PASSWORD '${PASS_DB_PASSERELLE}';
    CREATE USER combo;
    CREATE DATABASE combo TEMPLATE=template0 LC_COLLATE='fr_FR.UTF_8' LC_CTYPE='fr_FR.UTF-8';
    GRANT ALL PRIVILEGES ON DATABASE combo TO combo;
    ALTER USER combo WITH PASSWORD '${PASS_DB_COMBO}';
    CREATE USER fargo;
    CREATE DATABASE fargo TEMPLATE=template0 LC_COLLATE='fr_FR.UTF_8' LC_CTYPE='fr_FR.UTF-8';
    GRANT ALL PRIVILEGES ON DATABASE fargo TO fargo;
    ALTER USER fargo WITH PASSWORD '${PASS_DB_FARGO}';
    CREATE USER chrono;
    CREATE DATABASE chrono TEMPLATE=template0 LC_COLLATE='fr_FR.UTF_8' LC_CTYPE='fr_FR.UTF-8';
    GRANT ALL PRIVILEGES ON DATABASE chrono TO chrono;
    ALTER USER chrono WITH PASSWORD '${PASS_DB_CHRONO}';
    CREATE USER wcs CREATEDB;
    ALTER USER wcs WITH PASSWORD '${PASS_DB_WCS}';
    CREATE USER "authentic-multitenant";
    CREATE DATABASE authentic2_multitenant TEMPLATE=template0 LC_COLLATE='fr_FR.UTF_8' LC_CTYPE='fr_FR.UTF-8';
    GRANT ALL PRIVILEGES ON DATABASE authentic2_multitenant TO "authentic-multitenant";
    ALTER USER "authentic-multitenant" WITH PASSWORD '${PASS_DB_AUTHENTIC}';
    \c combo;
    CREATE EXTENSION unaccent;
    \c authentic2_multitenant;
    CREATE EXTENSION unaccent;
    CREATE EXTENSION pg_trgm;
    \c chrono;
    CREATE EXTENSION btree_gist;
EOSQL
