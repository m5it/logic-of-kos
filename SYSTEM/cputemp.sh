#!/bin/bash
#
CREATED="by Blaz Kos"
VERSION="Logic Of Kos - cputemp.sh - v13.37"
#
#--


#
G=$1

#
temp=$(cat /sys/class/thermal/thermal_zone0/temp)
#
if [[ $G == "-h" || $G == "--help" ]]; then
	echo "Help for "$0
	echo "----------------------------------------------------------"
	echo $CREATED
	echo "----------------------------------------------------------"
	echo "-n      # Show just number in celsius"
	echo "-N      # Show just number in celsius * 1000"
	exit
elif [[ $G == "-v" || $G == "--version" ]]; then
	echo $VERSION
	echo $CREATED
	exit
elif [[ $G == "-n" ]]; then
	echo $((temp/1000))
elif [[ $G == "-N" ]]; then
	echo $temp
else
	echo "CPU temperature: "$((temp/1000))"/C"
fi
