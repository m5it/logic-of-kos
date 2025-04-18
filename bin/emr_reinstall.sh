#!/bin/bash
#
CREATED="by Blaz Kos"
VERSION="Logic Of Kos - emr_reinstall.sh - v13.37"
#
#
#--

#
arg1="world"
arg2=false

#
if [[ $1 == "-h" || $1 == "--help" ]]; then
	echo "Help for "$0
	echo "------------------------------------------------------------"
	echo $CREATED
	echo "------------------------------------------------------------"
	echo "First argument: world, system, dev-lang/php..."
	echo "Second argument: true | false to act as pretend"
	echo ""
	echo "Usage ex.: "$0" world"
	echo "      ex.: "$0" world true"
	exit
elif [[ $1 == "-v" || $1 == "--version" ]]; then
	echo $VERSION
	echo $CREATED
	exit
fi
#
if [[ $1 != "" ]]; then
	arg1=$1    # world, system, dev-lang/php...
fi
#
if [[ $2 != "" ]]; then
	arg2=$2    # true
fi

echo "Reinstalling "$arg1"..."
#
if [[ $arg2 == false ]]; then
	emerge --ask --verbose -b -e $arg1
else
	emerge --ask --verbose -b -e --pretend $arg1
fi
