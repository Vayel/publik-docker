#!/bin/bash

. ./init-env.sh

docker-compose -f docker-compose.yml -f docker-compose.dev.yml build
docker-compose -f docker-compose.yml -f docker-compose.dev.yml pull rabbitmq pgadmin mailcatcher
