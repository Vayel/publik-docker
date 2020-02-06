#!/bin/bash

export-site.sh
for dir in /tmp/sites/*/
do
  if [ -d "$dir" ]; then
    ORG=${dir:11:-1}
    if [ "${ORG:0:1}" != "_" ]; then
      export-site.sh $ORG
    fi
  fi
done
