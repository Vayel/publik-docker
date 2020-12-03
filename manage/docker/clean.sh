#!/bin/bash

. ./init-env.sh

read -p "Are you sure to delete containers AND volumes AND images [y/n]? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  docker-compose -f docker-compose.yml -f docker-compose.dev.yml down -v --rmi 'all' --remove-orphans
  docker-compose -f docker-compose.yml -f docker-compose.dev.yml rm -v
fi
