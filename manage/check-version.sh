#!/bin/bash

d=`diff <(git log --name-status HEAD^..HEAD) ./images/components/commit-build.log`
if [ -z "$d" ]; then
  exit 0
fi
exit 1
