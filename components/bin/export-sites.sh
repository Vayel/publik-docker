#!/bin/bash

export-site.sh
for ORG in /tmp/sites/*/
do
  if [ -d "$ORG" ]; then
    ORG=${ORG:11:-1}
    export-site.sh $ORG
  fi
done
