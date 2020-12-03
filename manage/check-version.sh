#!/bin/bash

d=`git log --name-status HEAD^..HEAD | diff ./images/components/commit-build.log -`
if [ -z "$d" ]; then
  exit 0
fi

echo $d
exit 1
