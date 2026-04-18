#!/bin/bash
#
# Start/boot a VM network (set interfaces up/down)

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=true
PCA=("MACHINE_NAME" "ACTION" "WHICH" "DEBUG")

ARG_MACHINE_NAME=""
ARG_MACHINE_NAME_STRING=true
MACHINE_NAME_SHORT_ARG="-M"
MACHINE_NAME_ARG="--machine_name"
MACHINE_NAME_VAL=true

ARG_ACTION="up"
ARG_ACTION_STRING=true
ACTION_SHORT_ARG="-a"
ACTION_ARG="--action"
ACTION_VAL=true

ARG_WHICH="both"
ARG_WHICH_STRING=true
WHICH_SHORT_ARG="-w"
WHICH_ARG="--which"
WHICH_VAL=true

ARG_DEBUG=false
DEBUG_SHORT_ARG="-d"
DEBUG_ARG="--debug"
DEBUG_VAL=false

source $PRE'src/pca.sh'

debug_echo() {
	[[ "$ARG_DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

MACHINE_NAME="$ARG_MACHINE_NAME"
ACTION="${ARG_ACTION:-up}"
WHICH="${ARG_WHICH:-both}"

if [[ "$MACHINE_NAME" == "" ]]; then
	echo "Usage: $0 -M <machine_name> [-a <action>] [-w <which>]"
	echo "  -M, --machine_name: VM name (required)"
	echo "  -a, --action: Action: up or down (default: up)"
	echo "  -w, --which: Which: vm, master, or both (default: both)"
	echo "  -d, --debug: Show debug info"
	exit 1
fi

case "$ACTION" in
	up|down) ;;
	*)
		echo "ERROR: Invalid action '$ACTION'. Use 'up' or 'down'."
		exit 1
		;;
esac

case "$WHICH" in
	vm|master|both) ;;
	*)
		echo "ERROR: Invalid which '$WHICH'. Use 'vm', 'master', or 'both'."
		exit 1
		;;
esac

debug_echo "Action: $ACTION, Which: $WHICH, Machine: $MACHINE_NAME"

if [[ "$WHICH" == "master" || "$WHICH" == "both" ]]; then
	debug_echo "Setting master interface $ACTION: ve-$MACHINE_NAME"
	ip link set "ve-$MACHINE_NAME" "$ACTION"
fi

if [[ "$WHICH" == "vm" || "$WHICH" == "both" ]]; then
	debug_echo "Setting VM interface $ACTION inside: $MACHINE_NAME"
	systemd-run -M "$MACHINE_NAME" --pipe ip link set host0 "$ACTION"
fi

echo "Done. Network $ACTION for: $MACHINE_NAME ($WHICH)"