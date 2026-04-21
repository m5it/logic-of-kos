#!/bin/bash
#
# Port forwarding (DNAT) - forward traffic from one IP:port to another

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("IN_INT" "FROM_PORT" "TO_IP" "TO_PORT" "YES" "DEBUG")

ARG_IN_INT=""
ARG_IN_INT_STRING=true
IN_INT_SHORT_ARG="-i"
IN_INT_ARG="--in-int"
IN_INT_VAL=true

ARG_FROM_PORT=""
ARG_FROM_PORT_STRING=true
FROM_PORT_SHORT_ARG="-f"
FROM_PORT_ARG="--from-port"
FROM_PORT_VAL=true

ARG_TO_IP=""
ARG_TO_IP_STRING=true
TO_IP_SHORT_ARG="-t"
TO_IP_ARG="--to-ip"
TO_IP_VAL=true

ARG_TO_PORT=""
ARG_TO_PORT_STRING=true
TO_PORT_SHORT_ARG="-o"
TO_PORT_ARG="--to-port"
TO_PORT_VAL=true

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

IN_INT="${ARG_IN_INT:-enp2s0}"
FROM_PORT="${ARG_FROM_PORT:-8080}"
TO_IP="${ARG_TO_IP}"
TO_PORT="${ARG_TO_PORT:-8080}"
YES="${ARG_YES:-false}"

if [[ "$TO_IP" == "" ]]; then
	echo "ERROR: -t (--to-ip) is required"
	exit 1
fi

debug_echo "IN_INT=$IN_INT, FROM_PORT=$FROM_PORT, TO_IP=$TO_IP, TO_PORT=$TO_PORT"

echo "Port forwarding configuration:"
echo "  In interface: $IN_INT"
echo "  From port: $FROM_PORT"
echo "  To IP: $TO_IP"
echo "  To port: $TO_PORT"

if [[ "$YES" != "true" ]]; then
	echo ""
	echo "Is this correct? (Y/n)"
	read CONFIRM
	if [[ "$CONFIRM" != "Y" ]]; then
		echo "Exiting."
		exit 1
	fi
fi

debug_echo "Adding DNAT rule: $IN_INT:$FROM_PORT -> $TO_IP:$TO_PORT"

iptables -t nat -A PREROUTING -i "$IN_INT" -p tcp --dport "$FROM_PORT" -j DNAT --to-destination "$TO_IP:$TO_PORT"

echo "Done. Port $FROM_PORT forwarded to $TO_IP:$TO_PORT"
