#!/bin/bash

. ./init-env.sh

docker-compose -f docker-compose.yml -f docker-compose.db.yml build
docker-compose -f docker-compose.yml -f docker-compose.db.yml pull rabbitmq pgadmin
