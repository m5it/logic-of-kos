#!/bin/bash
# Script to faster configuration of ips on master and slave host. Delete and recreate IPs for nspawned systems.
# Tested with systems that use veth type of interfaces.
#
# Using lok framework and it scripts for simplicity.

PRE=$(dirname $(realpath $0))"/../"

source $PRE'src/prepare.sh'

#--
# Define variables for pca.sh ( parse command line arguments )
#--
PCA_ON_NONE_HELP=true

PCA=("MACHINE_NAME" "THIRD_OCT" "YES")

# MACHINE_NAME argument
ARG_MACHINE_NAME=""
ARG_MACHINE_NAME_STRING=true
MACHINE_NAME_SHORT_ARG="-M"
MACHINE_NAME_ARG="--machine_name"
MACHINE_NAME_VAL=true

# THIRD_OCT argument
ARG_THIRD_OCT=""
ARG_THIRD_OCT_STRING=true
THIRD_OCT_SHORT_ARG="-T"
THIRD_OCT_ARG="--third_oct"
THIRD_OCT_VAL=true

# YES argument
ARG_YES=""
ARG_YES_STRING=false
YES_SHORT_ARG="-Y"
YES_ARG="--yes"
YES_VAL=false

source $PRE'src/pca.sh'

MACHINE_NAME=$ARG_MACHINE_NAME
THIRD_OCT=$ARG_THIRD_OCT

if [[ ! -n "$MACHINE_NAME" || "$MACHINE_NAME" == "" ]]; then
	echo "Missing argument MACHINE_NAME"
	exit 1
fi

if [[ ! -n "$THIRD_OCT" || "$THIRD_OCT" == "" ]]; then
	echo "Missing argument THIRD_OCT"
	exit 1
fi

# 1.) Delete VM Master Interface IPs
/usr/local/bin/msdnet -M $MACHINE_NAME -Y

# 2.) Create new ip, route, broadcast for VM Master Interface
/usr/local/bin/lok syd CREATE_MASTER_NET SET IP=192.168.$THIRD_OCT.241
/usr/local/bin/lok syd CREATE_MASTER_NET SET PREFIX=28
/usr/local/bin/lok syd CREATE_MASTER_NET SET ROUTE=192.168.$THIRD_OCT.240
/usr/local/bin/lok syd CREATE_MASTER_NET SET BROADCAST=192.168.$THIRD_OCT.255
/usr/local/bin/lok syd CREATE_MASTER_NET SET INTERFACE=ve-$MACHINE_NAME

if [[ "$ARG_YES" != "true" ]]; then
	/usr/local/bin/lok syd CREATE_MASTER_NET VIEW
	echo "Is this correct? (Y/n...)"
	read TMP
	if [[ "$TMP" != "Y" ]]; then
		echo "Work it out and come back... Exiting."
		exit 1
	fi
	echo "Continue.."
fi

/usr/local/bin/lok syd CREATE_MASTER_NET RUN

# 3.) Delete VM IPs
/usr/local/bin/vmdnet -M $MACHINE_NAME -Y

# 4.) Create VM IPs
/usr/local/bin/vmcnet -M $MACHINE_NAME -Y

echo "Done..."