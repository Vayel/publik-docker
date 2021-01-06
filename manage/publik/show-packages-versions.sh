#!/bin/bash

docker exec components apt-cache policy authentic2-multitenant combo fargo hobo hobo-agent passerelle wcs wcs-au-quotidien publik-common

echo
echo
echo "Compare with latest versions: https://deb.entrouvert.org"
