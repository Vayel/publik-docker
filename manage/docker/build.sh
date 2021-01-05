#!/bin/bash

. ./manage/init-env.sh

git log --name-status HEAD^..HEAD > images/components/commit-build.log

docker-compose -f docker-compose.yml build "$@"
docker-compose -f docker-compose.yml pull rabbitmq
