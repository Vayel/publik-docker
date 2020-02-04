#!/bin/bash

. ./init-env.sh

docker-compose -f docker-compose.yml -f docker-compose.db.yml build
docker-compose -f docker-compose.certificates.yml build

docker-compose -f docker-compose.yml pull rabbitmq
docker-compose -f docker-compose.certificates.yml pull debian
