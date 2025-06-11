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
#
ARG_LINK=false
ARG_UNLINK=false
ARG_ACTION="VIEW" # LINK | UNLINK
ARG_LOCATION=()
#
PCA_ON_NONE_HELP=true
PCA=("LINK UNLINK LOCATION FIX DEBUG")
#
LINK_SHORT_ARG="-l"
LINK_ARG="--link"
LINK_VAL=false
LINK_FUNCTION(){
	ARG_ACTION='LINK'
}
#
UNLINK_SHORT_ARG="-u"
UNLINK_ARG="--unlink"
UNLINK_VAL=false
UNLINK_FUNCTION(){
	ARG_ACTION='UNLINK'
}
#
LOCATION_SHORT_ARG="-L"
LOCATION_ARG="--location"
LOCATION_VAL=true
#
FIX_SHORT_ARG="-F"
FIX_ARG="--fix_install"
FIX_VAL=false
FIX_FUNCTION(){
	ARG_ACTION="FIX"
}
#
DEBUG_SHORT_ARG="-d"
DEBUG_ARG="--debug"
DEBUG_VAL=false
DEBUG_FUNCTION(){
	ARG_ACTION="DEBUG"
}
#--
# Parse command line arguments
source $PRE'pca.sh'

#--
# CHECK
echo "Overview of setting: "
echo "Action ARG_ACTION: "$ARG_ACTION
echo "Action ARG_LOCATION: "$ARG_LOCATION
echo "Action ARG_LINK: "$ARG_LINK
echo "Action ARG_UNLINK: "$ARG_UNLINK
echo "Action ARG_FIX: "$ARG_FIX
echo "Action ARG_DEBUG: "$ARG_DEBUG
echo "Location: "$CNF_LOCATION

#--
# Change location to install
if [[ $ARG_LOCATION == true ]]; then
	echo "Enter new install location: "
	read -r ARG_LOCATION
	echo "Changing link location from "$CNF_LOCATION" to "$ARG_LOCATION
	source $PRE'continue.sh'
	echo "LOCATION "$ARG_LOCATION > install.cnf
	exit
elif [[ $ARG_LOCATION != "" ]]; then
	echo "Changing link location from "$CNF_LOCATION" to "${ARG_LOCATION[0]}
	source $PRE'continue.sh'
	echo "LOCATION "${ARG_LOCATION[0]} > install.cnf
	exit
fi


#
if [[ $ARG_ACTION == "LINK" && -f $CNF_INSTALL ]]; then # check if already installed
	echo "First uninstall / unlink then reinstall. Thanks"
	exit
fi

#--
# SET ACTION LOOP
if [[ $ARG_ACTION == 'UNLINK' ]]; then
	ARRAY=$(cat $CNF_INSTALL)
	rm $CNF_INSTALL
else
	ARRAY=$(find . -maxdepth 2 ! -name "pca.sh" ! -name "isadmin.sh" ! -name "install.sh" ! -name 'continue.sh' ! -name 'prepare.sh' ! -path './tests*' ! -name 'test*' | grep -E "*.sh+$|*.py+$|*.php+$")
fi

#
if [[ $ARG_ACTION != "VIEW" && $ARG_ACTION != "DEBUG" ]]; then
	#
	source $PRE'isadmin.sh' # check if root
fi
#
if [[ $ARG_ACTION != "VIEW" && $ARG_ACTION != "DEBUG" ]]; then
	source $PRE'continue.sh' # check if continue
fi
#
if [[ $ARG_FIX == true ]]; then
	echo "Fixing install.dbk"
	rm $CNF_INSTALL
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
	if [[ $ARG_ACTION == "DEBUG" ]]; then
		echo "DEBUG file: "$file", name: "$name", namx: "$namx", lfrom: "$lfrom", lto: "$lto
	elif [[ $ARG_ACTION == "FIX" ]]; then
		echo "FIX "$file" -> "$lto
		echo $file >> $CNF_INSTALL
	#
	elif [[ $ARG_ACTION == "LINK" ]]; then
		if [[ -L $lto ]]; then
			echo "WARNING LINKING: link exists "$namx
		elif [[ -f $lto ]]; then
			echo "ERROR LINKING: file exists "$namx
		else
			echo "LINKING: "$lfrom" -> "$lto
			ln -s $lfrom $lto
			echo $file >> $CNF_INSTALL
		fi
	#
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
