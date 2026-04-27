#!/bin/bash
#
# Create network interfaces (bridge, veth)

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("ACTION" "TYPE" "NAME" "PEER" "ROUTE" "PREFIX" "MAC" "PEER_MAC" "YES" "DEBUG")

ARG_ACTION=""
ARG_ACTION_STRING=true
ACTION_SHORT_ARG="-a"
ACTION_ARG="--action"
ACTION_VAL=true

ARG_TYPE=""
ARG_TYPE_STRING=true
TYPE_SHORT_ARG="-t"
TYPE_ARG="--type"
TYPE_VAL=true

ARG_NAME=""
ARG_NAME_STRING=true
NAME_SHORT_ARG="-n"
NAME_ARG="--name"
NAME_VAL=true

ARG_PEER=""
ARG_PEER_STRING=true
PEER_SHORT_ARG="-e"
PEER_ARG="--peer"
PEER_VAL=true

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

ARG_MAC=""
ARG_MAC_STRING=true
MAC_SHORT_ARG="-m"
MAC_ARG="--mac"
MAC_VAL=true

ARG_PEER_MAC=""
ARG_PEER_MAC_STRING=true
PEER_MAC_SHORT_ARG="-M"
PEER_MAC_ARG="--peer-mac"
PEER_MAC_VAL=true

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
TYPE="${ARG_TYPE:-bridge}"
NAME="${ARG_NAME}"
PEER="${ARG_PEER}"
ROUTE="${ARG_ROUTE:-192.168.3.1}"
PREFIX="${ARG_PREFIX:-24}"
MAC="${ARG_MAC}"
PEER_MAC="${ARG_PEER_MAC}"
YES="${ARG_YES:-false}"

debug_echo "ACTION=$ACTION, TYPE=$TYPE, NAME=$NAME, PEER=$PEER, ROUTE=$ROUTE, PREFIX=$PREFIX, MAC=$MAC, PEER_MAC=$PEER_MAC"

echo "$TYPE $ACTION:"
echo "  Name: $NAME"
[[ -n "$PEER" ]] && echo "  Peer: $PEER"
echo "  Route: $ROUTE/$PREFIX"
[[ -n "$MAC" ]] && echo "  MAC: $MAC"
[[ -n "$PEER_MAC" ]] && echo "  Peer MAC: $PEER_MAC"

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
	if [[ "${TYPE}" == "bridge" ]]; then
		debug_echo "Creating bridge $NAME with $ROUTE/$PREFIX"
		ip link add "$NAME" type bridge
		[[ -n "$MAC" ]] && ip link set "$NAME" address "$MAC"
		ip addr add "$ROUTE/$PREFIX" brd + dev "$NAME"
		ip link set "$NAME" up
		echo "Done. Bridge $NAME created at $ROUTE/$PREFIX"
	elif [[ "${TYPE}" == "veth" ]]; then
		debug_echo "Creating veth pair: $NAME <-> $PEER"
		ip link add "$NAME" type veth peer name "$PEER"
		[[ -n "$MAC" ]] && ip link set "$NAME" address "$MAC"
		[[ -n "$PEER_MAC" ]] && ip link set "$PEER" address "$PEER_MAC"
		ip link set "$NAME" up
		ip link set "$PEER" up
		echo "Done. veth pair created: $NAME <-> $PEER"
	else
		echo "ERROR: Invalid type '$TYPE'. Use bridge or veth"
		echo "Use '$0 -h' for help"
		exit 1
	fi
elif [[ "${ACTION^^}" == "DELETE" || "${ACTION^^}" == "DEL" ]]; then
	if [[ "${TYPE}" == "bridge" ]]; then
		debug_echo "Deleting bridge $NAME"
		ip link set "$NAME" down
		ip addr del "$ROUTE/$PREFIX" dev "$NAME" 2>/dev/null
		ip link delete "$NAME"
		echo "Done. Bridge $NAME deleted"
	elif [[ "${TYPE}" == "veth" ]]; then
		debug_echo "Deleting veth pair: $NAME <-> $PEER"
		ip link delete "$NAME"
		echo "Done. veth pair deleted: $NAME"
	else
		echo "ERROR: Invalid type '$TYPE'. Use bridge or veth"
		echo "Use '$0 -h' for help"
		exit 1
	fi
else
	echo "ERROR: Invalid action '$ACTION'. Use ADD or DELETE"
	echo "Use '$0 -h' for help"
	exit 1
fi
