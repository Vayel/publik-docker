#!/bin/bash

for comp in authentic2-multitenant combo chrono fargo hobo passerelle wcs
do
  if [ "$comp" == "authentic2-multitenant" ]; then
    user="authentic-multitenant"
  else
    user=$comp
  fi
  chown -R $user:$user "/var/lib/$comp"
done
