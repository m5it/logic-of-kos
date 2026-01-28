#!/bin/bash

# Replace these with your actual database credentials
SOURCE_HOST="lokkal.com"
SOURCE_USER="pub4all"
SOURCE_PASS="7gMeafZ"
SOURCE_DB="dlokkal.com_myvents"

# Replace these with your destination database credentials
DEST_HOST="127.0.0.1"
DEST_USER="pub4all"
DEST_PASS="7gMeafZ"
DEST_DB="lokkal.com_myvents"

# Get list of tables from source DB
TABLES=$(mariadb -h "$SOURCE_HOST" -u "$SOURCE_USER" -p"$SOURCE_PASS" -P3307 -N -s -e "use dlokkal.com_myvents;show tables;" --skip-ssl)
echo $TABLES

# Run pt-table-sync for all tables
pt-table-sync --execute \
  h="$SOURCE_HOST" u="$SOURCE_USER" p="$SOURCE_PASS" D="$SOURCE_DB" t="$TABLES" \
  h="$DEST_HOST" u="$DEST_USER" p="$DEST_PASS" D="$DEST_DB"

echo "Sync Done for "$DEST_DB" !"
