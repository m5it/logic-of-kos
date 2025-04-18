#!/bin/bash
# A script to remove comments and empty lines from file
FROM=$1
echo "Removing from...: "$FROM
echo ""

cat $FROM | sed -e "/^#/g" | sed -r "/^\s*$/d"

echo ""
echo "Done."
