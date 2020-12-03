#!/bin/bash

echo ""

echo "*****************************"
echo "* Last commit in local repo *"
echo "*****************************"
echo ""
git log --name-status HEAD^..HEAD

echo ""
echo ""

echo "****************************"
echo "* Last commit in container *"
echo "****************************"
echo ""
docker exec components cat /tmp/commit-build.log

echo ""
