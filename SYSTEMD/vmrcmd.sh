#!/bin/bash
# Run command in systemd-nspawn container

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=true
PCA=("MACHINE_NAME" "YES")

ARG_MACHINE_NAME=""
ARG_MACHINE_NAME_STRING=true
MACHINE_NAME_SHORT_ARG="-M"
MACHINE_NAME_ARG="--machine"
MACHINE_NAME_VAL=true

ARG_YES=""
ARG_YES_STRING=false
YES_SHORT_ARG="-Y"
YES_ARG="--yes"
YES_VAL=false

source $PRE'src/pca.sh'

MACHINE_NAME="${ARG_MACHINE_NAME}"
YES="${ARG_YES:-false}"

if [[ -z "$MACHINE_NAME" || ! -n "$MACHINE_NAME" ]]; then
	echo "Usage: $0 -M <machine_name> [cmd...]"
	echo "  $0 -M contabo-last"
	echo "  $0 -M contabo-last 'ls -la /'"
	exit 1
fi

shift $((APCA + 1))
CMD="${@}"

if [[ "$YES" != "true" ]]; then
	echo "Running command in machine: $MACHINE_NAME"
	echo "Command: $CMD"
	echo "Continue? (Y/n)"
	read TMP
	if [[ "$TMP" != "Y" ]]; then
		echo "Exiting."
		exit 1
	fi
fi

if [[ -n "$CMD" ]]; then
	systemd-run -M $MACHINE_NAME --pipe $CMD
else
	systemd-run -M $MACHINE_NAME --pipe /bin/bash
fi
