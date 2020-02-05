#!/bin/bash

ORG=
if [ "$#" -ne 0 ]; then
  ORG=$1.
fi
export ORG

for COMP in authentic2-multitenant combo fargo hobo passerelle wcs
do
  subst.sh "/etc/nginx/conf.d/$COMP.template" "/etc/nginx/conf.d/$COMP.${ORG}conf"
  subst.sh "/etc/nginx/conf.d/$COMP.${ORG}conf" "/etc/nginx/conf.d/$COMP.${ORG}conf" '$ORG'
done
