#!/bin/bash

PGPASSWORD="$PASS_POSTGRES" pg_dumpall -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" | gzip > /tmp/db_dump.gz
