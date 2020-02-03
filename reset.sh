#!/bin/bash

. ./init-env.sh

docker-compose -f docker-compose.yml -f docker-compose.db.yml down -v
docker-compose -f docker-compose.yml -f docker-compose.db.yml rm -v
