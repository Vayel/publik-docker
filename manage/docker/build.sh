#!/bin/bash

. ./init-env.sh

git log --name-status HEAD^..HEAD > images/components/commit-build.log

docker-compose -f docker-compose.yml -f docker-compose.dev.yml build "$@"
docker-compose -f docker-compose.yml -f docker-compose.dev.yml pull rabbitmq pgadmin mailcatcher
docker-compose -f docker-compose.restorer.yml build
