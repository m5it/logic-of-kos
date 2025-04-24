#!/bin/bash
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
PCA=("IDENTIFY UMOUNT FORMAT CREATE PATH")
# Define variables where options are parsed as values
ARG_IDENTIFY="" # defined value from command line arguments OR true
ARG_UMOUNT=""   # /dev/sdb2...
ARG_FORMAT=""   # ext4, ext3, xfs, vfat...
ARG_CREATE=""   # someimage.iso
ARG_PATH=""     # /dev/sdbX

#-- forma - options
# Options for arg IDENTIFY 
IDENTIFY_SHORT_ARG="-i"          #
IDENTIFY_ARG="--identify"        #
IDENTIFY_VAL=false               # true | false ( if argument contain value )
IDENTIFY_FUNCTION(){
	lsblk | grep -v 'loop' # exclude loop mounts
	exit
}

# Options for arg UMOUNT
UMOUNT_SHORT_ARG="-u"            #
UMOUNT_ARG="--umount"            #
UMOUNT_VAL=false                 # true | false ( if argument contain value )

# Options for arg FORMAT
FORMAT_SHORT_ARG="-f"
FORMAT_ARG="--format"
FORMAT_VAL=true

# Options for arg CREATE bootable usb from iso or img with dd
CREATE_SHORT_ARG="-c"
CREATE_ARG="--create"
CREATE_VAL=true
#
PATH_SHORT_ARG="-p"
PATH_ARG="--path"
PATH_VAL=true 

#--
# Parse command line arguments
source $PRE'pca.sh'
#
#echo "ARG_IDENTIFY: "$ARG_IDENTIFY
#echo "ARG_UMOUNT: "$ARG_UMOUNT
#echo "ARG_FORMAT: "$ARG_FORMAT
#echo "ARG_CREATE: "$ARG_CREATE
#echo "ARG_PATH: "$ARG_PATH

#
source $PRE'isadmin.sh'

#--
# (MAIN) Start the script

#
# Umount partition / directory
if [[ $ARG_UMOUNT == true ]]; then
	# Check if ARG_PATH exists
	CHK=$(mount | grep $ARG_PATH)
	if [[ $CHK == "" ]]; then
		echo "ERROR: path "$ARG_PATH" dont exists. Exiting."
		exit
	fi
	#
	echo "Umounting "$ARG_PATH
	source $PRE'continue.sh'
	umount $ARG_PATH
fi

# Format partition
tmp=""
cnt=0
if [[ $ARG_FORMAT != "" ]]; then
	# PERFORM SOME CHECKS
	if [[ $(echo $ARG_PATH | grep -E "*.([0-9])+$") == "" ]]; then
		echo "Looks you are trying to format disk without partitions. This tool is used to format partition and not entire disk!"
		exit
	fi
	#
	echo "Formating "$ARG_FORMAT" "$ARG_PATH
	source $PRE'continue.sh'
	#tmp=$(yes | mkfs.$ARG_FORMAT $ARG_UMOUNT 2>&1 >/dev/null)
	mkfs.$ARG_FORMAT $ARG_PATH
fi

# Create new bootable usb
if [[ $ARG_CREATE != "" ]]; then
	# Check if ARG_PATH exists
	CHK=$(mount | grep $ARG_PATH)
	if [[ $CHK != "" ]]; then
		echo "ERROR: path "$ARG_PATH" is mounted. Umount first. Exiting."
		exit
	fi
	echo "Create: "$ARG_CREATE" on "$ARG_PATH
	source $PRE'continue.sh'
	dd if=$ARG_CREATE of=$ARG_PATH bs=4M status=progress
fi

