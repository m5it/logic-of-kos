#!/bin/bash
#
#--
# Script to link bin/*.sh files to /usr/local/bin/...
# bin/*.sh are tools for system programs that give you more instructions, helping notifications then current programs installed from scratch.
# Means to be user friendly when using terminal and bash.
#--

#--
# PREPARE VARIABLES
PRE=""
source prepare.sh
CNF_LOCATION=$(cat install.cnf | awk '/LOCATION/{print $2}')
CNF_INSTALL="install.dbk"

#--
# HANDLE ARGUMENTS & OPTIONS & CONFIGURATIONS
ARG_ACTION="VIEW" # LINK | UNLINK
#
for arg in "$@"; do
	if [[ $arg == "-h" || $arg == "--help" ]]; then
        	echo "Help for "$B"...:"
			cat $P'/'$PRE'hr.txk'
	        cat $P'/'$PRE'created.txk'
        	echo $V
	        cat $P'/'$PRE'hr.txk'
	        if [[ -f $H ]]; then
				cat $H
			else
				echo "\nSorry can not find documentation for this script.\n"
			fi
        	exit
	elif [[ $arg == "-v" || $arg == "--version" ]]; then
		echo $V
		exit
	elif [[ $arg == "-t" || $arg == "--link-to" ]]; then
		echo "Changing link location from "$CNF_LOCATION
        	read -r CNF_LOCATION
	        echo "LOCATION "$CNF_LOCATION > install.cnf
	elif [[ $arg == "-l" || $arg == "--action-link" ]]; then
		ARG_ACTION="LINK"
	elif [[ $arg == "-u" || $arg == "--action-unlink" ]]; then
		ARG_ACTION="UNLINK"
	fi
done

#--
# CHECK
echo "Overview of setting: "
echo "Action: "$ARG_ACTION
echo "Location: "$CNF_LOCATION
#
if [[ $ARG_ACTION != "VIEW" && $UID -ne 0 ]]; then
	echo "Required super adminitrator privileges. Exiting..."
	exit
fi
#
source $P'/'continue.sh

#--
#
if [[ $ARG_ACTION == 'UNLINK' ]]; then
	ARRAY=$(cat $CNF_INSTALL)
	rm $CNF_INSTALL
else
	ARRAY=$(find . ! -name '$CNF_INSTALL' ! -path './tests*' | grep -P ".sh+$")
fi

#--
# DO ACTION
for file in $ARRAY; do
	#
	file=$(echo -n $file | sed "s/^\.\///g")
	name=$(basename $file)
	namx=$(echo -n $name | sed "s/\.sh//g")
	lfrom=$(pwd)"/"$file
	lto=$CNF_LOCATION""$namx
	#
	if [[ $ARG_ACTION == "LINK" ]]; then
		if [[ -L $lto ]]; then
			echo "WARNING LINKING: link exists "$namx
		elif [[ -f $lto ]]; then
			echo "ERROR LINKING: file exists "$namx
		else
			echo "LINKING: "$lfrom" -> "$lto
			ln -s $lfrom $lto
			echo $file >> $CNF_INSTALL
		fi
	elif [[ $ARG_ACTION == "UNLINK" ]]; then
		if [[ -L $lto ]]; then
                        echo "UNLINKING: "$lto
			rm $lto
                elif [[ -f $lto ]]; then
                        echo "ERROR UNLINKING: it is file "$lto
                else
                        echo "WARNING UNLINKING (missing): "$lto
                fi
	else
		echo $name
	fi
done
