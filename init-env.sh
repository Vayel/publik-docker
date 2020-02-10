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

mkdir -p data

if [ ! -f .env ]; then
  cp .env.template .env
fi

if [ ! -f data/config.env ]; then
  cp config.env.template data/config.env
fi

if [ ! -f data/secret.env ]; then
  cp secret.env.template data/secret.env
  generate_passwords data/secret.env
fi

# If we don't create it ourselves a folder is created instead of a file
mkdir -p data
for fname in hosts
do
  if [ ! -f "./data/$fname" ]; then
    touch "./data/$fname"
  fi
done
