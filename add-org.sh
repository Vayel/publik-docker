#!/bin/bash

set -eu

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters"
  echo 'Help: ./add-org.sh my-organization "My organization"'
  exit 1
fi

export SLUG=$1
export TITLE="$2"
DIR="data/sites/$SLUG"

echo "Creating $DIR..."
echo "Slug: $SLUG"
echo "Title: $TITLE"

mkdir -p $DIR
envsubst '$SLUG $TITLE' < hobo-recipe.json.template > "$DIR/hobo-recipe.json.template"
