#!/bin/bash
#
#--
# Script to link bin/*.sh files to /usr/local/bin/...
# bin/*.sh are tools for system programs that give you more instructions, helping notifications then current programs installed from scratch.
# Means to be user friendly when using terminal and bash.

#--
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/"
source $PRE'prepare.sh' # include prepared global variables like: realpath, filenick, filename..
#
CNF_LOCATION=$(cat install.cnf | awk '/LOCATION/{print $2}')
CNF_INSTALL="install.dbk"
CNF_EXCLUDE=""
# generate exclude if exists: exclude.cnf
#IFS=$'\n'
#while read -r tmp; do
#cat 'exclude.cnf' | while read -r tmp; do
#for tmp in `cat exclude.cnf`; do
#	echo "tmp: "$tmp
#	#CNF_EXCLUDE=$(echo -n $tmp' | ' && cat)
#	#CNF_EXCLUDE=$CNF_EXCLUDE" | "$tmp" "
#done
#done <'exclude.cnf'
#echo "CNF_EXCLUDE: "$CNF_EXCLUDE
#exit
#--
# HANDLE ARGUMENTS & OPTIONS & CONFIGURATIONS
ARG_ACTION="VIEW" # LINK | UNLINK
#
for arg in "$@"; do
	if [[ $arg == "-h" || $arg == "--help" ]]; then
        	echo "Help for "$B"...:"
			cat $PRE'hr.txk'
	        cat $PRE'created.txk'
        	echo $V
	        cat $PRE'hr.txk'
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
if [[ $ARG_ACTION == "LINK" && -f $CNF_INSTALL ]]; then # check if already installed
	echo "First uninstall / unlink then reinstall. Thanks"
	exit
fi

#
if [[ $ARG_ACTION != "VIEW" ]]; then
	#
	source $PRE'isadmin.sh' # check if root
fi

#
source $PRE'continue.sh' # check if continue

#--
# SET ACTION LOOP
if [[ $ARG_ACTION == 'UNLINK' ]]; then
	ARRAY=$(cat $CNF_INSTALL)
	rm $CNF_INSTALL
else
	ARRAY=$(find . ! -name "pca.sh" ! -name "isadmin.sh" ! -name "install.sh" ! -name 'continue.sh' ! -name 'prepare.sh' ! -path './tests*' ! -name 'test*' | grep -E "*.sh+$")
	#ARRAY=$(find . $CNF_EXCLUDE | grep -P ".sh+$")
	#ARRAY=`find . `$CNF_EXCLUDE` | grep -P ".sh+$"`
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
