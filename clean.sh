#!/bin/bash

. ./init-env.sh

docker-compose -f docker-compose.yml -f docker-compose.dev.yml down -v --rmi 'all' --remove-orphans
docker-compose -f docker-compose.yml -f docker-compose.dev.yml rm -v
