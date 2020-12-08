#!/bin/bash

. ./manage/init-env.sh

docker-compose -f docker-compose.certificates.yml build
docker-compose -f docker-compose.certificates.yml pull debian
