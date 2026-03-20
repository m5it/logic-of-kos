#!/bin/bash
#
# LOK Framework: prepare.sh, continue.sh, isadmin.sh, pca.sh
#
#--
#
echo "Do you like to continune? (y/n)"
read -r CHK
if [[ $CHK != "y" ]]; then
	exit
fi
