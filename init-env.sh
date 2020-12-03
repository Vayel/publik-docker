#!/bin/bash

function generate_passwords {
  cp "$1" "$1.tmp"
  echo "" > "$1"
  cat "$1.tmp" | while read line; do
    if [[ "$line" =~ ^PASS_[A-Z0-9_]+=$ ]]; then
      pass=`date +%s | sha256sum | base64 | head -c 32 ; echo`
      echo "$line$pass" >> "$1"
      sleep 1  # To increase the date
    else
      echo "$line" >> "$1"
    fi
  done
  rm "$1.tmp"
}

mkdir -p data

./init-ssl.sh

if [ ! -f .env ]; then
  cp .env.template .env
  generate_passwords .env
fi

# If we don't create it ourselves a folder is created instead of a file
if [ ! -f "./data/hosts" ]; then
  touch "./data/hosts"
fi
