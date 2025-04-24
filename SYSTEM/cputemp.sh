#!/bin/bash
#
#
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
PCA_ON_NONE_HELP=false
# Define array of available argument options
PCA=("TEMPERATURE TEMPERATURE_CELSIUS")
# Define variables where options are parsed as values
ARG_TEMPERATURE=false           # true | false
ARG_TEMPERATURE_CELSIUS=false   # true | false

#-- forma - options
# Options for arg IDENTIFY 
TEMPERATURE_SHORT_ARG="-t"
TEMPERATURE_ARG="--temperature"
TEMPERATURE_VAL=false               # true | false ( if argument contain value )
#TEMPERATURE_FUNCTION(){
#	echo "TEMPERATURE_FUNCTION EXAMPLE..."
#	exit
#}
#
TEMPERATURE_CELSIUS_SHORT_ARG="-T"
TEMPERATURE_CELSIUS_ARG="--temperature_celsius"
TEMPERATURE_CELSIUS_VAL=false

#--
# Parse command line arguments
source $PRE'pca.sh'

#--
# DEBUG ARGS: 
#echo "ARG_TEMPERATURE: "$ARG_TEMPERATURE
#echo "ARG_TEMPERATURE_CELSIUS: "$ARG_TEMPERATURE_CELSIUS

#--
# MAIN START
#
temp=$(cat /sys/class/thermal/thermal_zone0/temp)
#
if [[ $ARG_TEMPERATURE == true ]]; then
	echo $temp
#
elif [[ $ARG_TEMPERATURE_CELSIUS == true ]]; then
	echo $((temp/1000))
#
else
	echo "CPU temperature: "$((temp/1000))"/C"
fi

