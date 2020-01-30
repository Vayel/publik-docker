#!/bin/bash

for file in config.env .env secret.env
do
  if [ ! -f $file ]; then
    cp "$file.template" $file
  fi
done

export COMPOSE_PROJECT_NAME=publik
