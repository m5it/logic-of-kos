#!/bin/bash
#
#
#--
# Prepare global variables and data
PRE="../"               # perfix
source prepare.sh       # include prepared global variables like: realpath, filenick, filename..

#--
# Define variables for pca.sh ( parse command line arguments )
#--
# Options for arg IDENTIFY 
IDENTIFY_SHORT_ARG="-i"          #
IDENTIFY_ARG="--identify"        #
IDENTIFY_VAL=false               # true | false ( if argument contain value )
# Options for arg UMOUNT
UMOUNT_SHORT_ARG="-u"          #
UMOUNT_ARG="--umount"        #
UMOUNT_VAL=false               # true | false ( if argument contain value )
# Options for arg FORMAT

#--
# Define array of available argument options
PCA=("IDENTIFY UMOUNT")

#--
# Define variables where options are parsed as values
ARG_IDENTIFY="" # defined value from command line arguments OR true
ARG_UMOUNT=""

#--
# Parse command line arguments
source $P"/"$PRE"pca.sh"

#--
# (MAIN) Start the script
echo "ARG_IDENTIFY: "$ARG_IDENTIFY
echo "ARG_UMOUNT: "$ARG_UMOUNT
