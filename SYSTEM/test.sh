#!/bin/bash
#
PRE="../"               # perfix
source prepare.sh       # include prepared global variables like: realpath, filenick, filename..

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
#
ARG_IDENTIFY="" # defined value from command line arguments
#
source $P"/"$PRE"pca.sh"

#
echo "ARG_IDENTIFY: "$ARG_IDENTIFY
