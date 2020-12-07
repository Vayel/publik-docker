#!/bin/bash

docker exec components apt-cache policy combo passerelle fargo hobo hobo-agent authentic2-multitenant wcs wcs-au-quotidien

echo "Compare with latest versions on https://deb.entrouvert.org/"
