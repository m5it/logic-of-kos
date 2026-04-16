#!/bin/bash
#
# Script to delete all ips of systemd-nspawn vm machine veth type
#
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/../"
#
source $PRE'src/prepare.sh' # include prepared global variables like: realpath, filenick, filename..
#--
# Define variables for pca.sh ( parse command line arguments )
#--
# Display help if no args set...
PCA_ON_NONE_HELP=true
PCA=("MACHINE_NAME" "YES")

ARG_MACHINE_NAME=""           # ip address
ARG_MACHINE_NAME_STRING=true
MACHINE_NAME_SHORT_ARG="-M"
MACHINE_NAME_ARG="--machine_name"
MACHINE_NAME_VAL=true

ARG_YES=""
ARG_YES_STRING=false
YES_SHORT_ARG="-Y"
YES_ARG="--yes"
YES_VAL=false

# Parse command line arguments
source $PRE'src/pca.sh'
#
MACHINE_NAME=$ARG_MACHINE_NAME
#
#echo "Deleting ips from machine: "$MACHINE_NAME". Is correct? (Y / n)"
#read -r TMP
#if [[ "$TMP" != "Y" ]]; then
#	echo "Exiting..."
#	exit 1
#fi
if [[ ! -n "$MACHINE_NAME" || "$MACHINE_NAME" == "" ]]; then
	echo "Missing argument MACHINE_NAME"
	exit 1
fi

if [[ "$ARG_YES" != "true" ]]; then
	echo "Continuing... Sleep 3s"
	sleep 3
fi
#
CNT=0
IFS=$'\n'
for line in $(systemd-run -M $MACHINE_NAME --pipe ip addr show host0); do
	trim=$(echo $line | sed 's/^[[:space:]]*//')
	echo "trim: "$trim
	# inet 192.168.224.98/28 scope global host0
	if [[ "$trim" =~ ^inet[[:space:]]+([0-9]{1,3}\.){3}.+([16|24|28|32]).+scope.+global.+host0 ]]; then
				IFS=' ' read -r -a arr <<< "$trim"
				#echo "debug: "${arr[@]}
				if ! systemd-run -M $MACHINE_NAME --pipe ip addr delete ${arr[1]} dev ${arr[4]}; then
						echo "ERROR deleting ip "${arr[1]}" dev "${arr[4]}
						exit 1
				else
						CNT=$((CNT += 1 ))
				fi
	fi
done
echo "Done. Removed ips: "$CNT
