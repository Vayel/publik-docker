#!/bin/bash

. ./init-env.sh

docker-compose -f docker-compose.yml -f docker-compose.db.yml up --no-build --abort-on-container-exit
