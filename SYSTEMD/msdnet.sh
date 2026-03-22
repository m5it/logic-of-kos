#!/bin/bash
# Script to delete all ips of vm machine on master host using veth type
#
MACHINE_NAME=$1
#
if [[ $# == 0 || "$MACHINE_NAME" == "" ]]; then
	echo "Usage: "$0" [machineName]"
	exit 1
fi
echo "Deleting ips from interface: ve-"$MACHINE_NAME". Is correct? (Y / n)"
read TMP
if [[ "$TMP" != "Y" ]]; then
	echo "Exiting..."
	exit 1
fi

echo "Continuing..."
CNT=0
IFS=$'\n'
for line in $(ip addr show "ve-"$MACHINE_NAME); do
	trim=$(echo $line | sed 's/^[[:space:]]*//')
	# inet 169.254.119.99/16 metric 2048 brd 169.254.255.255 scope link ve-ldbp.raw
	if [[ "$trim" =~ ^inet[[:space:]]+([0-9]{1,3}\.){3}.+([16|24|28|32]).+metric.+([0-9]).+brd.+([0-9{1,3}\.]+){3}.+scope.+link.+ve\-$MACHINE_NAME ]]; then
		IFS=' ' read -r -a arr <<< "$trim"
		ip addr delete ${arr[1]} brd ${arr[5]} dev ${arr[8]}
		CNT=$((CNT += 1 ))
	# inet 192.168.216.113/28 brd 192.168.216.127 scope global ve-ldbp.raw
	elif [[ "$trim" =~ ^inet[[:space:]]+([0-9]{1,3}\.){3}.+([16|24|28|32]).+scope.+global.+ve\-$MACHINE_NAME+$ ]]; then
		IFS=' ' read -r -a arr <<< "$trim"
		ip addr delete ${arr[1]} brd ${arr[3]} dev ${arr[6]}
		CNT=$((CNT += 1))
	else
		echo "fail: "$trim
	fi
done
echo "Done. Num deleted ips: "$CNT
