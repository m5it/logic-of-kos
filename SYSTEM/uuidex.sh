#!/bin/bash
#
# uuidex - extract UUID or PARTUUID from a block device
#

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("DEVICE" "PARTUUID")

ARG_DEVICE=""
ARG_DEVICE_STRING=true
DEVICE_SHORT_ARG="-D"
DEVICE_ARG="--device"
DEVICE_VAL=true

ARG_PARTUUID=false
PARTUUID_SHORT_ARG="-p"
PARTUUID_ARG="--partuuid"
PARTUUID_VAL=false

source $PRE'src/pca.sh'

[[ -z "$ARG_DEVICE" && -n "$1" && "$1" != -* ]] && ARG_DEVICE="$1"

DEVICE="${ARG_DEVICE}"
OUTPUT_TYPE="UUID"
[[ "$ARG_PARTUUID" == "true" ]] && OUTPUT_TYPE="PARTUUID"

if [[ -z "$DEVICE" ]]; then
	echo "Usage: $B -D <device> [-p]"
	echo "  -D, --device   Path to block device (e.g., /dev/sda)"
	echo "  -p, --partuuid Output PARTUUID instead of UUID"
	exit 1
fi

UUID=$(blkid -o value -s UUID "$DEVICE")
PARTUUID=$(blkid -o value -s PARTUUID "$DEVICE")

if [[ "$OUTPUT_TYPE" == "PARTUUID" ]]; then
	echo "$PARTUUID"
else
	echo "$UUID"
fi
