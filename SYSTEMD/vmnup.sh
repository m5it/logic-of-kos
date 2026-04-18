#!/bin/bash
#
if [[ "$1" == "" ]]; then
	echo "Exiting. Missing [MACHINE_NAME]..."
	exit 1
fi
#
MACHINE_NAME=$1
# set master host interface up
ip link set ve-$MACHINE_NAME up
# set vm interface up
systemd-run -M $MACHINE_NAME --pipe ip link set host0 up
