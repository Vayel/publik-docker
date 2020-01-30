#!/bin/bash

. ./init-env.sh

docker-compose -f docker-compose.yml -f docker-compose.db.yml -p $COMPOSE_PROJECT_NAME build
docker-compose -p $COMPOSE_PROJECT_NAME pull rabbitmq
