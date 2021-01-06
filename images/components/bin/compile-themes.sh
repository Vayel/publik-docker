#!/bin/bash

set -eu

. colors.sh

BASE_DIR=$1
BASE_THEME_DIR=/usr/share/publik/publik-base-theme

cd $BASE_DIR
if [ ! -d "publik-base-theme" ] || [ -z "$(ls -A publik-base-theme)" ]; then
  rsync -r $BASE_THEME_DIR/* publik-base-theme --exclude .git
fi

cd $BASE_DIR/themes
for theme in *
do
  cd $BASE_DIR

  static_dir=$BASE_DIR/themes/$theme/static

  echo "Making data URIs for $theme..."
	make_theme_data_uris.py --source $static_dir/images/ \
    --source $BASE_DIR/publik-base-theme/static/includes/img/ \
    --dest $static_dir/_data_uris.scss \
    --dest $BASE_DIR/publik-base-theme/static/includes/_data_uris.scss

  if [[ "$theme" = __* ]]; then
    echo "Skipping CSS compilation for abstract theme $theme"
  else
    echo "Compiling CSS for $theme..."
    cd $static_dir && sassc style.scss style.css
    rm -rf $static_dir/.sass-cache/
  fi
done

echo_success "Themes compiled."
