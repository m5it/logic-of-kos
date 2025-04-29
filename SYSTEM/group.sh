#!/bin/bash
#
#
#
#--
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/../"
source $PRE'prepare.sh' # include prepared global variables like: realpath, filenick, filename..

#--
# Define variables for pca.sh ( parse command line arguments )
#--
# Display help if no args set...
PCA_ON_NONE_HELP=true
# Define array of available argument options
# - (CREATE) create new group
# - (ADDTO) user addto group
PCA=("CREATE ADDTO VIEW")
# Define variables where options are parsed as values
ARG_CREATE=()
ARG_ADDTO=()
ARG_VIEW=()
#-- forma - options
# Options for arg CREATE
CREATE_SHORT_ARG="-c"        #
CREATE_ARG="--create"        #
CREATE_VAL=true               # true | false ( if argument contain value )
#
ADDTO_SHORT_ARG="-aG"
ADDTO_ARG="--add_group"
ADDTO_VAL=true               # true | false ( if argument contain value )
ADDTO_VNM=2                   # how many values have this arg (default 1)
#
VIEW_SHORT_ARG="-V"
VIEW_ARG="--view"
VIEW_VAL=true

#--
# Parse command line arguments
source $PRE'pca.sh'
#
source $PRE'isadmin.sh'
#echo "DEBUG ARGS: "
#echo "ARG_ADDTO: "${ARG_ADDTO[2]}
#echo "ARG_CREATE: "${ARG_CREATE[@]}
#echo "ARG_VIEW: "${ARG_VIEW[@]}
#
if [[ $ARG_VIEW != "" ]]; then
	if [[ ${ARG_VIEW[0]} != true ]]; then
		cat /etc/group | grep "${ARG_VIEW[0]}"
	else
		cat /etc/group
	fi
fi
#
if [[ $ARG_CREATE != "" ]]; then
	echo "Creating group "${ARG_CREATE[@]}
	source $PRE'continue.sh'
	groupadd ${ARG_CREATE[0]}
fi
#
if [[ $ARG_ADDTO != "" ]]; then
	echo "Adding user "${ARG_ADDTO[1]}" to group "${ARG_ADDTO[0]}
	source $PRE'continue.sh'
	usermod -aG ${ARG_ADDTO[0]} ${ARG_ADDTO[1]}
fi
