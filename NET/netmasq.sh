#!/bin/bash
#
# NAT masquerade - enable packet forwarding between interfaces

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("FROM_IF" "TO_IF" "YES" "DEBUG")

ARG_FROM_IF=""
ARG_FROM_IF_STRING=true
FROM_IF_SHORT_ARG="-f"
FROM_IF_ARG="--from-if"
FROM_IF_VAL=true

ARG_TO_IF=""
ARG_TO_IF_STRING=true
TO_IF_SHORT_ARG="-t"
TO_IF_ARG="--to-if"
TO_IF_VAL=true

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

FROM_IF="${ARG_FROM_IF}"
TO_IF="${ARG_TO_IF}"
YES="${ARG_YES:-false}"

if [[ "$FROM_IF" == "" || "$TO_IF" == "" ]]; then
	echo "ERROR: Both -f (--from-if) and -t (--to-if) are required"
	exit 1
fi

debug_echo "FROM_IF=$FROM_IF, TO_IF=$TO_IF"

echo "Masquerade configuration:"
echo "  From interface: $FROM_IF"
echo "  To interface: $TO_IF"

if [[ "$YES" != "true" ]]; then
	echo ""
	echo "Is this correct? (Y/n)"
	read CONFIRM
	if [[ "$CONFIRM" != "Y" ]]; then
		echo "Exiting."
		exit 1
	fi
fi

debug_echo "Adding masquerade: $FROM_IF -> $TO_IF"

iptables -t nat -A POSTROUTING -o "$FROM_IF" -j MASQUERADE
iptables -A FORWARD -i "$FROM_IF" -o "$TO_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i "$TO_IF" -o "$FROM_IF" -j ACCEPT
iptables -A INPUT -i "$TO_IF" -p udp -m udp --dport 67 -j ACCEPT

echo "Done. Masquerade enabled for $FROM_IF -> $TO_IF"
