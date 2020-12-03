#!/bin/bash

. ./init-env.sh

if ! ./check-version.sh; then
  echo "/!\\/!\\/!\\"
  echo "WARNING: last-build commit different from current commit. Rebuild needed?"
  echo "/!\\/!\\/!\\"
  echo ""
fi

docker-compose -f docker-compose.yml -f docker-compose.prod.yml up --no-build -d
