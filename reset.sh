#!/bin/bash

. ./init-env.sh

docker-compose -f docker-compose.yml -f docker-compose.db.yml -p $COMPOSE_PROJECT_NAME down -v
docker-compose -f docker-compose.yml -f docker-compose.db.yml -p $COMPOSE_PROJECT_NAME rm -v
