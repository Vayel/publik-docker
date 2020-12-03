#!/bin/bash

# Fail on errors
set -eu

service combo stop
service passerelle stop
service fargo stop
service hobo stop
service supervisor stop
service supervisor start
service authentic2-multitenant stop
service wcs stop
service nginx stop

# Pause 2 seconds
sleep 2
