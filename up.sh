#!/bin/bash

. ./init-env.sh

docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --no-build --abort-on-container-exit
