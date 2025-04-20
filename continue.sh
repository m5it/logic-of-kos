#!/bin/bash
#
#
#
#--
#
echo "Do you like to continune? (y/n)"
read -r CHK
if [[ $CHK != "y" ]]; then
	exit
fi
