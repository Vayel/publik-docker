#!/bin/bash

. ./load-env.sh

docker-compose -p $COMPOSE_PROJECT_NAME build
docker-compose -p $COMPOSE_PROJECT_NAME pull pgadmin rabbitmq mailcatcher
