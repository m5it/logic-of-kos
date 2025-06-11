#!/bin/bash
#
#
#
#
#
#--
#echo "PWD: "$(pwd)
#echo "0: "$0
#echo "0 real: "$(realpath $0)
#echo "0 base: "$(basename $(realpath $0))
#exit
#--
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/"
source $PRE'prepare.sh' # include prepared global variables like: realpath, filenick, filename..

#--
# Configure PCA
#
CNF_INSTALL="install.dbk"
#
#ARG_INSTALL=false
#ARG_UNINSTALL=false
ARG_PREVIEW=false
ARG_AVAILABLE=false
#
#PCA=("INSTALL UNINSTALL PREVIEW")
PCA=("AVAILABLE PREVIEW UNINSTALL")
#
PCA_ON_NONE_HELP=true
#
#INSTALL_SHORT_ARG="-i"
#INSTALL_ARG="--install"
#INSTALL_VAL=false
#
UNINSTALL_SHORT_ARG="-u"
UNINSTALL_ARG="--uninstall"
UNINSTALL_VAL=false
#
PREVIEW_SHORT_ARG="-p"
PREVIEW_ARG="--preview"
PREVIEW_VAL=false
#
AVAILABLE_SHORT_ARG="-a"
AVAILABLE_ARG="--available"
AVAILABLE_VAL=false

# Parse command line arguments
source $PRE"pca.sh"

echo "DEBUG args: "
#echo "ARG_INSTALL: "$ARG_INSTALL
echo "ARG_UNINSTALL: "$ARG_UNINSTALL
echo "ARG_PREVIEW: "$ARG_PREVIEW
echo "ARG_AVAILABLE: "$ARG_AVAILABLE
echo "ARG_HELP: "$ARG_HELP

#--
# MAin START
#if [[ $ARG_INSTALL == true ]]; then
#	echo "LOK => Installing"
#	source $PRE'install.sh' -l
if [[ $ARG_UNINSTALL == true ]]; then
	echo "LOK => Uninstalling..."
	source $PRE'continue.sh' # check if continue
	source $PRE'install.sh' -u
elif [[ $ARG_PREVIEW == true ]]; then
	echo "LOK => Preview..."
	#
	for data in $(cat $CNF_INSTALL); do
		fn=$(basename $data|sed 's/\.sh//g')
		echo $fn
	done
elif [[ $ARG_AVAILABLE == true ]]; then
	echo "LOK => Available..."
	#
	find . -maxdepth 2 ! -name "pca.sh" ! -name "isadmin.sh" ! -name "install.sh" ! -name 'continue.sh' ! -name 'prepare.sh' ! -path './tests*' ! -name 'test*' | grep -E "*.sh+$|*.py+$|*.php+$"
else
	echo "LOK => ELSE..."
fi

