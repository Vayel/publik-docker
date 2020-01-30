#!/bin/bash

function generate_passwords {
  cp "$1" "$1.tmp"
  echo "" > "$1"
  cat "$1.tmp" | while read line; do
    if [[ "$line" =~ ^[A-Z0-9_]+=$ ]]; then
      pass=`date +%s | sha256sum | base64 | head -c 32 ; echo`
      echo "$line$pass" >> "$1"
      sleep 1  # To increase the date
    else
      echo $line >> "$1"
    fi
  done
  rm "$1.tmp"
}

for file in config.env .env secret.env
do
  if [ ! -f $file ]; then
    cp "$file.template" $file
    if [ "$file" == "secret.env" ]; then
      generate_passwords "$file"
    fi
  fi
done

export COMPOSE_PROJECT_NAME=publik
