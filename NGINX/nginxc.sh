#!/bin/bash
# Script to create password for virtual host on nginx
#
#--
USER=${1}
FILE="/etc/nginx/.htpasswd"
#
if [[ "$USER" == "" ]]; then
	echo "Specify username."
	exit
fi
#
if [[ -f "$FILE" ]]; then
	CHK=$(cat $FILE | grep "$USER")
	if [[ "$CHK" != "" ]]; then
		echo "Looks "$USER" exists. Exiting..."
		exit
	fi
fi
#
echo "Using file: "$FILE" with username: "$USER". Is this correct? (Y/N)"
read TMP
if [[ "$TMP" != "Y" ]]; then
	exit
fi
#
D1=$USER
D2=$(openssl passwd -apr1)
#
if [[ "$D2" != "" ]]; then
	echo $D1":"$D2 >> $FILE
fi
echo "DONE..."
