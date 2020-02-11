#!/bin/bash

. ./init-env.sh

docker-compose -f docker-compose.yml -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.yml -f docker-compose.dev.yml rm -v
