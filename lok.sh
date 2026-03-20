#!/bin/bash
# From v0.1 available syntax:
#----------------------------
# Ex.:
# lok -l
# lok -u
# lok -p
# cputemp
# etc...
#
# From v0.2 available syntax:
#----------------------------
# Ex.: 
#   lok NET calcnipp HELP
#   lok NET calcnipp SET somekey=28
#   lok NET calcnipp SET somekey 28
#   lok NET calcnipp GET somekey
#   lok NET calcnipp VIEW
#   lok NET calcnipp RUN

# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/"
echo "DEBUG d1 PRE: "$PRE
source $PRE'src/prepare.sh' # include prepared global variables like: realpath, filenick, filename..

#--
# Configure PCA
#
CNF_INSTALL=$PRE"install.dbk"
#echo "DEBUG lok.sh => PRE: "$PRE", CNF_INSTALL: "$CNF_INSTALL
#
#ARG_INSTALL=false
ARG_UNINSTALL=false
ARG_PREVIEW=false
ARG_AVAILABLE=false
#
PCA=("AVAILABLE PREVIEW UNINSTALL")
#
PCA_ON_NONE_HELP=false
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

# PARSE command line arguments
source $PRE"src/pca.sh"

echo "DEBUG args: "
#echo "ARG_INSTALL: "$ARG_INSTALL
echo "ARG_UNINSTALL: "$ARG_UNINSTALL
echo "ARG_PREVIEW: "$ARG_PREVIEW
echo "ARG_AVAILABLE: "$ARG_AVAILABLE
echo "ARG_HELP: "$ARG_HELP

#--
# MAIN
#--
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
	find $PRE -maxdepth 2 ! -name "pca.sh" ! -name "isadmin.sh" ! -name "install.sh" ! -name 'continue.sh' ! -name 'prepare.sh' ! -path './tests*' ! -name 'test*' | grep -E "*.sh+$|*.py+$|*.php+$"
else
	echo "LOK => ELSE..."
fi

