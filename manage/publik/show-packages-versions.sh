#!/bin/bash

packages=( authentic2-multitenant combo fargo hobo hobo-agent passerelle wcs wcs-au-quotidien publik-common )
env_vars=( AUTHENTIC_VERSION COMBO_VERSION FARGO_VERSION HOBO_VERSION HOBO_AGENT_VERSION PASSERELLE_VERSION WCS_VERSION WCS_AU_QUOTIDIEN_VERSION PUBLIK_COMMON_VERSION )

for ((i=0;i<${#packages[@]};++i))
do
  v=`docker exec components apt-cache policy ${packages[i]} | sed -n '2p' | cut -c 16-`
  echo "${env_vars[i]}=$v"
done

echo
echo
echo "Compare with latest versions on https://deb.entrouvert.org/"
