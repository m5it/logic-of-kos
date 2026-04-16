#!/bin/bash
# Script to delete all ips of systemd-nspawn vm machine on master host using veth type
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
# Define array of available argument options
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
for line in $(ip addr show "ve-"$MACHINE_NAME); do
	trim=$(echo $line | sed 's/^[[:space:]]*//')
	# inet 169.254.119.99/16 metric 2048 brd 169.254.255.255 scope link ve-ldbp.raw
	if [[ "$trim" =~ ^inet[[:space:]]+([0-9]{1,3}\.){3}.+([16|24|28|32]).+metric.+([0-9]).+brd.+([0-9{1,3}\.]+){3}.+scope.+link.+ve\-.* ]]; then
		IFS=' ' read -r -a arr <<< "$trim"
		if ! ip addr delete ${arr[1]} brd ${arr[5]} dev ${arr[8]}; then
			echo "ERROR deleting ip "${arr[1]}" brd "${arr[5]}" dev "${arr[8]}
			exit 1
		else
			CNT=$((CNT += 1 ))
		fi
	# inet 192.168.216.113/28 brd 192.168.216.127 scope global ve-ldbp.raw
	elif [[ "$trim" =~ ^inet[[:space:]]+([0-9]{1,3}\.){3}.+([16|24|28|32]).+scope.+global.+ve\-.* ]]; then
		IFS=' ' read -r -a arr <<< "$trim"
		if ! ip addr delete ${arr[1]} brd ${arr[3]} dev ${arr[6]}; then
			echo "ERROR deleting ip "${arr[1]}" brd "${arr[3]}" dev "${arr[6]}
			exit 1
		else
			CNT=$((CNT += 1 ))
		fi
	else
		echo "fail: "$trim
	fi
done
echo "Done. Num deleted ips: "$CNT
