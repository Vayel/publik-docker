#!/bin/bash

. ./manage/init-env.sh

read -p "Are you sure to delete both containers AND volumes [y/n]? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  docker-compose -f docker-compose.yml -f docker-compose.dev.yml down -v
  docker-compose -f docker-compose.yml -f docker-compose.dev.yml rm -v
fi
