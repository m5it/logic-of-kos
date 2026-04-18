#!/bin/bash
#
# Script to block IP or range using whois info

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("TARGET" "ACTION" "DEBUG")

ARG_TARGET=""
ARG_TARGET_STRING=true
TARGET_SHORT_ARG="-t"
TARGET_ARG="--target"
TARGET_VAL=true

ARG_ACTION="SHOW"
ARG_ACTION_STRING=true
ACTION_SHORT_ARG="-a"
ACTION_ARG="--action"
ACTION_VAL=true

ARG_DEBUG=false
DEBUG_SHORT_ARG="-d"
DEBUG_ARG="--debug"
DEBUG_VAL=false

source $PRE'src/pca.sh'

debug_echo() {
	[[ "$ARG_DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

TARGET="${ARG_TARGET}"
ACTION="${ARG_ACTION:-SHOW}"

if [[ "$TARGET" == "" ]]; then
	echo "Usage: $0 -t <ip_or_host> [-a <SHOW|DROP|DEBUG>]"
	echo "  -t, --target: IP address or hostname"
	echo "  -a, --action: Action: SHOW, DROP, or DEBUG (default: SHOW)"
	exit 1
fi

debug_echo "Target: $TARGET, Action: $ACTION"

if [[ "$TARGET" =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9])+$ ]]; then
	IP="$TARGET"
else
	IP=$(host "$TARGET" 2>/dev/null | awk '!/IPv6/ && /address/ {print $4}')
	[[ -z "$IP" ]] && { echo "ERROR: Could not resolve $TARGET"; exit 1; }
fi

debug_echo "Resolved IP: $IP"

TMPWHOIS=$(mktemp)
whois "$IP" > "$TMPWHOIS" 2>/dev/null

NETRANGE=$(grep NetRange "$TMPWHOIS" | awk '{print $2"-"$4}')
INETNUM=$(grep inetnum "$TMPWHOIS" | awk '{print $2"-"$4}')
rm "$TMPWHOIS"

debug_echo "NetRange: $NETRANGE, Inetnum: $INETNUM"

if [[ "$ACTION" == "SHOW" || "$ACTION" == "DEBUG" ]]; then
	if [[ -n "$INETNUM" ]]; then
		echo "Inetnum: $INETNUM"
	elif [[ -n "$NETRANGE" ]]; then
		echo "NetRange: $NETRANGE"
	else
		echo "ERROR: Could not find range for $IP"
		exit 1
	fi
fi

if [[ "$ACTION" == "DROP" || "$ACTION" == "DEBUG" ]]; then
	if [[ -n "$INETNUM" ]]; then
		RANGE="$INETNUM"
	elif [[ -n "$NETRANGE" ]]; then
		RANGE="$NETRANGE"
	fi
	
	if [[ -n "$RANGE" ]]; then
		start=$(echo "$RANGE" | awk '{print $1}')
		end=$(echo "$RANGE" | awk '{print $2}')
		
		if [[ -z "$end" || "$end" == "$start" ]]; then
			[[ "$end" == "$start" ]] || end="$start"
			iptables -A INPUT -s "$start" -j DROP
			echo "Blocked IP: $start"
		else
			iptables -A INPUT -m iprange --src-range "$start-$end" -j DROP
			echo "Blocked range: $start-$end"
		fi
	fi
fi