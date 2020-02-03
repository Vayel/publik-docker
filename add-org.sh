#!/bin/bash

set -eu

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters"
  echo 'Help: ./add-org.sh my-organization "My organization"'
  exit 1
fi

export SLUG=$1
export TITLE="$2"
DIR=data/site/recipes
DEST="$DIR/$SLUG.json.template"

echo "Creating $DEST..."
echo "Slug: $SLUG"
echo "Title: $TITLE"

mkdir -p $DIR
envsubst '$SLUG $TITLE' < recipe.json.template > $DEST
