#!/bin/bash
#
# Create network bridge

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("ACTION" "NAME" "ROUTE" "PREFIX" "YES" "DEBUG")

ARG_ACTION=""
ARG_ACTION_STRING=true
ACTION_SHORT_ARG="-a"
ACTION_ARG="--action"
ACTION_VAL=true

ARG_NAME=""
ARG_NAME_STRING=true
NAME_SHORT_ARG="-n"
NAME_ARG="--name"
NAME_VAL=true

ARG_ROUTE=""
ARG_ROUTE_STRING=true
ROUTE_SHORT_ARG="-r"
ROUTE_ARG="--route"
ROUTE_VAL=true

ARG_PREFIX=""
ARG_PREFIX_STRING=true
PREFIX_SHORT_ARG="-p"
PREFIX_ARG="--prefix"
PREFIX_VAL=true

ARG_YES=""
ARG_YES_STRING=false
YES_SHORT_ARG="-Y"
YES_ARG="--yes"
YES_VAL=false

ARG_DEBUG=false
DEBUG_SHORT_ARG="-d"
DEBUG_ARG="--debug"
DEBUG_VAL=false

source $PRE'src/pca.sh'

debug_echo() {
	[[ "$ARG_DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

ACTION="${ARG_ACTION:-ADD}"
NAME="${ARG_NAME:-br0}"
ROUTE="${ARG_ROUTE:-192.168.3.1}"
PREFIX="${ARG_PREFIX:-24}"
YES="${ARG_YES:-false}"

debug_echo "ACTION=$ACTION, NAME=$NAME, ROUTE=$ROUTE, PREFIX=$PREFIX"

echo "Bridge $ACTION:"
echo "  Name: $NAME"
echo "  Route: $ROUTE/$PREFIX"

if [[ "$YES" != "true" ]]; then
	echo ""
	echo "Is this correct? (Y/n)"
	read CONFIRM
	if [[ "$CONFIRM" != "Y" ]]; then
		echo "Exiting."
		exit 1
	fi
fi

if [[ "${ACTION^^}" == "ADD" ]]; then
	debug_echo "Creating bridge $NAME with $ROUTE/$PREFIX"
	ip link add "$NAME" type bridge
	ip addr add "$ROUTE/$PREFIX" brd + dev "$NAME"
	ip link set "$NAME" up
	echo "Done. Bridge $NAME created at $ROUTE/$PREFIX"
elif [[ "${ACTION^^}" == "DELETE" || "${ACTION^^}" == "DEL" ]]; then
	debug_echo "Deleting bridge $NAME"
	ip link set "$NAME" down
	ip addr del "$ROUTE/$PREFIX" dev "$NAME"
	ip link delete "$NAME"
	echo "Done. Bridge $NAME deleted"
else
	echo "ERROR: Invalid action '$ACTION'. Use ADD or DELETE"
	echo "Use '$0 -h' for help"
	exit 1
fi
