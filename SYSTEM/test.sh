#!/bin/bash
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

# 
IDENTIFY_SHORT_ARG="-i"          #
IDENTIFY_ARG="--identify"        #
IDENTIFY_VAL=false               # true | false ( if argument contain value )
function IDENTIFY_FUNCTION(){    #
	echo "This is function identify!"
	exit
}
#
PCA=("IDENTIFY")
PCA_ON_NONE_HELP=false
#
ARG_IDENTIFY="" # defined value from command line arguments
#
source $PRE'src/pca.sh'

#
echo "ARG_IDENTIFY: "$ARG_IDENTIFY

#
pwd
dd=$(SYSTEM/test.sh -a -b -c def)

echo "done! "$dd
