#!/bin/bash
#
# Script to get IP geo info with caching using geoiplookup
#

PRE=$(dirname $(realpath $0))"/../"

which geoiplookup >/dev/null 2>&1 || {
	echo "geoiplookup not found."
	echo "Install geoip-bin package:"
	echo "  sudo apt install geoip-bin"
	exit 1
}

source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=true
PCA=("IP" "FORCE" "CLEAR")

ARG_IP=""
ARG_IP_STRING=true
IP_SHORT_ARG="-i"
IP_ARG="--ip"
IP_VAL=true

ARG_FORCE=false
FORCE_SHORT_ARG="-f"
FORCE_ARG="--force"
FORCE_VAL=false

ARG_CLEAR=false
CLEAR_SHORT_ARG="-c"
CLEAR_ARG="--clear"
CLEAR_VAL=false

source $PRE'src/pca.sh'

DATADIR="$D/NET/ipcome"
CACHE_DAYS=90

mkdir -p "$DATADIR"

get_hash() {
	local ip=$1
	echo -n "$ip" | md5sum | awk '{print $1}'
}

save_data() {
	local ip=$1
	local hash=$(get_hash "$ip")
	local file="$DATADIR/${hash}.txt"
	local timestamp=$(date +%s)
	
	{
		echo "# IP: $ip"
		echo "# HASH: $hash"
		echo "# TIMESTAMP: $timestamp"
		echo "# TIMESTAMP_READABLE: $(date -d @$timestamp '+%Y-%m-%d %H:%M:%S')"
		echo ""
		cat
	} > "$file"
}

load_data() {
	local ip=$1
	local hash=$(get_hash "$ip")
	local file="$DATADIR/${hash}.txt"
	
	if [[ ! -f "$file" ]]; then
		return 1
	fi
	
	local timestamp=$(grep "^# TIMESTAMP:" "$file" | cut -d':' -f2 | tr -d ' ')
	local now=$(date +%s)
	local expiration=$((CACHE_DAYS * 24 * 60 * 60))
	
	if [[ -n "$timestamp" && $((now - timestamp)) -gt $expiration ]]; then
		return 2
	fi
	
	local skip=1
	while read -r line; do
		if [[ -z "$skip" ]]; then
			echo "$line"
		elif [[ "$line" =~ ^# ]]; then
			continue
		else
			skip=
			echo "$line"
		fi
	done < "$file"
	
	return 0
}

get_geo() {
	local ip=$1
	
	echo "$ip" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$'
	if [[ $? -eq 0 ]]; then
		geoiplookup "$ip" 2>/dev/null
		if [[ $? -ne 0 ]]; then
			echo "Geo lookup failed for $ip"
			return 1
		fi
	else
		echo "Invalid IP address: $ip"
		return 1
	fi
}

if [[ -z "$ARG_IP" ]]; then
	echo "Usage: $0 -i <ip> [-f] [-c]"
	echo "  -i, --ip: IP address"
	echo "  -f, --force: Force refresh from geoiplookup"
	echo "  -c, --clear: Clear cached data for this IP"
	exit 1
fi

if [[ "$ARG_CLEAR" == "true" ]]; then
	hash=$(get_hash "$ARG_IP")
	file="$DATADIR/${hash}.txt"
	if [[ -f "$file" ]]; then
		rm "$file"
		echo "Cleared cache for $ARG_IP"
	else
		echo "No cache found for $ARG_IP"
	fi
	exit 0
fi

if [[ "$ARG_FORCE" == "true" ]]; then
	echo "Fetching fresh geo data for $ARG_IP..."
	get_geo "$ARG_IP" | save_data "$ARG_IP"
	get_geo "$ARG_IP"
	exit 0
fi

echo "Checking cache for $ARG_IP..."
data=$(load_data "$ARG_IP")
ret=$?

if [[ $ret -eq 0 && -n "$data" ]]; then
	echo "$data"
	echo ""
	echo "(from cache, younger than $CACHE_DAYS days)"
elif [[ $ret -eq 2 ]]; then
	echo "Cache expired, fetching fresh data..."
	get_geo "$ARG_IP" | save_data "$ARG_IP"
	get_geo "$ARG_IP"
else
	echo "No cache, fetching geo data..."
	get_geo "$ARG_IP" | save_data "$ARG_IP"
	get_geo "$ARG_IP"
fi