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
# Prepare global variables and data
PRE=""                  # perfix
source prepare.sh       # include prepared global variables like: realpath, filenick, filename..

#--
# Configure PCA
PCA_ON_NONE_HELP=true
#
INSTALL_SHORT_ARG="-i"
INSTALL_ARG="--install"
INSTALL_VAL=false
ARG_INSTALL=""
#
PCA=("INSTALL")
# Parse command line arguments
source $P"/"$PRE"pca.sh"

echo "DEBUG args: "
echo "ARG_INSTALL: "$ARG_INSTALL
