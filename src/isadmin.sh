#!/bin/bash
#
# LOK Framework: prepare.sh, continue.sh, isadmin.sh, pca.sh
#
#--
#
if [[ $UID -ne 0 ]]; then
	echo "Required super adminitrator privileges. Exiting..."
	exit
fi
