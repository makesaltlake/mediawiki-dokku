#!/bin/bash

. vars

if ! PGPASSWORD="$WIKI_DB_PASSWORD" psql -lqtU "$WIKI_DB_USER" -h "$WIKI_DB_HOST" -p "$WIKI_DB_PORT" | cut -d '|' -f 1 | grep -wq "$WIKI_DB_NAME" ; then
  echo "MediaWiki hasn't been set up yet. Run the setup script in this container to set things up."
  exit 1
fi

# This is a terrible way to do this. Maybe we can pull them into nginx config with a lua script or something?
# envsubst '$WIKI_HOST' < /etc/nginx/conf.d/mediawiki.conf.template > /etc/nginx/conf.d/mediawiki.conf
envsubst '
  $WIKI_NAME
  $WIKI_URL
  $WIKI_META_NAMESPACE
  $WIKI_DB_HOST
  $WIKI_DB_PORT
  $WIKI_DB_USER
  $WIKI_DB_PASSWORD
  $WIKI_DB_NAME
' < /app/LocalSettings.php > /var/www/mediawiki/LocalSettings.php
supervisord -c /scripts/supervisord.conf
