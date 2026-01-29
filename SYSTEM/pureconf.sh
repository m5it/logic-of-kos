#!/bin/bash
# Script to string comments and empty lines from file, normally config.
#   To get pure config without comments etc.. easier for sharing.
#--
FROM_FILE=$1
TO_FILE=$2
#
if [ "$FROM_FILE" == "" ]; then
	echo "FAIL: Usage "$0" \"php.ini\" \"stripped.php.ini\""
	echo "Exiting."
	exit
fi
#
if [ "$FROM_FILE" == "$TO_FILE" ]; then
	echo "WARNING: From and to files are the same. Normally not recommended! Exiting."
	exit
fi
#cat php.ini | sed '/^$/d; /^#/d; /^;/d' > newphp.ini
cat $FROM_FILE | sed '/^$/d; /^#/d; /^;/d' > $TO_FILE
