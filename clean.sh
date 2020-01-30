#!/bin/bash

. ./init-env.sh

docker-compose -p $COMPOSE_PROJECT_NAME down -v --rmi 'all' --remove-orphans
docker-compose -p $COMPOSE_PROJECT_NAME rm -v
