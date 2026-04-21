#!/bin/bash
#
# Create network bridge

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("NAME" "ROUTE" "PREFIX" "YES" "DEBUG")

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

NAME="${ARG_NAME:-br0}"
ROUTE="${ARG_ROUTE:-192.168.3.1}"
PREFIX="${ARG_PREFIX:-24}"
YES="${ARG_YES:-false}"

debug_echo "NAME=$NAME, ROUTE=$ROUTE, PREFIX=$PREFIX"

echo "Bridge configuration:"
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

debug_echo "Creating bridge $NAME with $ROUTE/$PREFIX"

ip link add "$NAME" type bridge
ip addr add "$ROUTE/$PREFIX" brd + dev "$NAME"
ip link set "$NAME" up

echo "Done. Bridge $NAME created at $ROUTE/$PREFIX"
