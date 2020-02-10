#!/bin/bash

mkdir -p data/ssl

if [ ! -f data/ssl/ticket.key ]; then
  echo "Generate HTTPS base certificates"
  openssl rand -out data/ssl/ticket.key 48
fi
if [ ! -f data/ssl/dhparam4.pem ]; then
  echo "Generate HTTPS base certificates"
  openssl dhparam -out data/ssl/dhparam4.pem 4096
fi
