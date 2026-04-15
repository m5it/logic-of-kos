#!/bin/bash
#
# Test script to verify history.sh functionality
#

PRE=$(dirname $(realpath $0))"/../"

source $PRE'src/prepare.sh'
source $PRE'src/history.sh'

PCA=("ARG1" "ARG2")

PCA_ON_NONE_HELP=true

ARG_ARG1=""
ARG_ARG1_STRING=true
ARG1_SHORT_ARG="-a"
ARG1_ARG="--arg1"
ARG1_VAL=true

ARG_ARG2=""
ARG_ARG2_STRING=true
ARG2_SHORT_ARG="-b"
ARG2_ARG="--arg2"
ARG2_VAL=true

source $PRE'src/pca.sh'

SN="justtest"
livedir="$DL/SYSTEMD/$SN"
livefile="$livedir/config"

if [[ ! -d "$livedir" ]]; then
	mkdir -p "$livedir"
fi

: > "$livefile"

if [[ -n "$ARG_ARG1" ]]; then
	echo "ARG1:$ARG_ARG1" >> "$livefile"
fi

if [[ -n "$ARG_ARG2" ]]; then
	echo "ARG2:$ARG_ARG2" >> "$livefile"
fi

if [[ ! -f "$livefile" ]]; then
	echo "Nothing to save"
	exit 0
fi

tmpdata=$(concat_lines "$livefile")
history_init "$SN"
history_add "$tmpdata"

echo ""
echo "Current history:"
history_list

echo ""
echo "Test complete!"