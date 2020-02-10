#!/bin/bash

echo "Generate HTTPS base certificates"
#######################################

mkdir -p data/ssl

# Generate certificates if needed
if [ ! -f data/ssl/ticket.key ]; then
  openssl rand -out data/ssl/ticket.key 48
fi
if [ ! -f data/ssl/dhparam4.pem ]; then
  openssl dhparam -out data/ssl/dhparam4.pem 4096
fi
