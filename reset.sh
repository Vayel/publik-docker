#!/bin/bash

. ./load-env.sh

docker-compose -p $COMPOSE_PROJECT_NAME down -v
docker-compose -p $COMPOSE_PROJECT_NAME rm -v
