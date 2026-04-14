#!/bin/bash
#
# Script to get IP/whois info with caching
#

PRE=$(dirname $(realpath $0))"/../"

source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=true
PCA=("IP" "FORCE" "CLEAR")

ARG_IP=""
ARG_IP_STRING=true
IP_SHORT_ARG="-i"
IP_ARG="--ip"
IP_VAL=true
IP_DEFAULT=true

ARG_FORCE=false
FORCE_SHORT_ARG="-f"
FORCE_ARG="--force"
FORCE_VAL=false

ARG_CLEAR=false
CLEAR_SHORT_ARG="-c"
CLEAR_ARG="--clear"
CLEAR_VAL=false

source $PRE'src/pca.sh'

for arg in "$@"; do
	[[ ! "$arg" =~ ^- ]] && [[ -n "$arg" ]] && [[ "$IP_DEFAULT" == true ]] && [[ "$ARG_IP" == "" || "$ARG_IP" == "true" ]] && ARG_IP="$arg"
done

DATADIR="$D/NET/ipis"
CACHE_DAYS=90

mkdir -p "$DATADIR"

#============================================================
# OLD CACHING SYSTEM (MD5 hash based)
#============================================================

get_hash() {
	local ip=$1
	echo -n "$ip" | md5sum | awk '{print $1}'
}

save_data() {
	local ip=$1
	local hash=$(get_hash "$ip")
	local file="$DATADIR/${hash}.txt"
	local timestamp=$(date +%s)
	
	cat > "$file" <<EOF
# IP: $ip
# HASH: $hash
# TIMESTAMP: $timestamp
# TIMESTAMP_READABLE: $(date -d @$timestamp '+%Y-%m-%d %H:%M:%S')

$1
EOF
}

load_data() {
	local ip=$1
	local hash=$(get_hash "$ip")
	local file="$DATADIR/${hash}.txt"
	
	[[ ! -f "$file" ]] && return 1
	
	local timestamp=$(grep "^# TIMESTAMP:" "$file" | cut -d':' -f2 | tr -d ' ')
	local now=$(date +%s)
	local expiration=$((CACHE_DAYS * 24 * 60 * 60))
	
	[[ -n "$timestamp" && $((now - timestamp)) -gt $expiration ]] && return 2
	
	sed '/^#/d' "$file"
	return 0
}

ip_to_num() {
	local ip=$1
	local num=0
	IFS='.' read -ra octets <<< "$ip"
	for oct in "${octets[@]}"; do
		num=$((num * 256 + oct))
	done
	echo "$num"
}

load_data_new() {
	local ip=$1
	local ip_num=$(ip_to_num "$ip")
	local found_file=""
	
	while read -r cache_file; do
		[[ ! -f "$cache_file" ]] && continue
		local full_key_path=$(echo "$cache_file" | sed "s|$DATADIR/||; s|\.txt$||")
		local range_start=$(echo "$full_key_path" | grep -oE '[13]_[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d'_' -f2)
		local suffix_part=$(echo "$full_key_path" | grep -oE '%.*$' | head -1)
		local range_prefix=24
		
		if [[ -n "$suffix_part" ]]; then
			range_prefix=$(echo "${suffix_part#*_}" | cut -d'/' -f2)
			[[ -z "$range_prefix" ]] && range_prefix=24
		else
			local range_end=$(echo "$full_key_path" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -1)
			[[ -z "$range_end" ]] && continue
		fi
		
		[[ -z "$range_start" ]] && continue
		
		local net_start=$(ip_to_num "$range_start")
		local mask=$((0xFFFFFFFF << (32 - range_prefix) & 0xFFFFFFFF))
		local net_end=$((net_start | (0xFFFFFFFF - mask)))
		
		if [[ $ip_num -ge $net_start && $ip_num -le $net_end ]]; then
			found_file="$cache_file"
			break
		fi
	done < <(find "$DATADIR" -name "*.txt" -type f 2>/dev/null)
	
	[[ -z "$found_file" ]] && return 1
	
	local timestamp=$(grep "^# TIMESTAMP:" "$found_file" | cut -d':' -f2 | tr -d ' ')
	local now=$(date +%s)
	local expiration=$((CACHE_DAYS * 24 * 60 * 60))
	
	[[ -n "$timestamp" && $((now - timestamp)) -gt $expiration ]] && return 2
	
	sed '/^#/d' "$found_file"
	return 0
}

#============================================================
# NEW CACHING SYSTEM (range based on whois info)
#============================================================

build_cache_key() {
	local whois_data="$1"
	local key=""
	
	local has_type1=$(echo "$whois_data" | grep -iE "^inetnum:" | head -1)
	local has_type2=$(echo "$whois_data" | grep -iE "^route:" | head -1)
	local has_type3=$(echo "$whois_data" | grep -iE "^NetRange:" | head -1)
	local has_type4=$(echo "$whois_data" | grep -iE "^CIDR:" | head -1)
	[[ -n "$has_type4" ]] && has_type4=$(echo "$has_type4" | sed 's|/|-|g')
	
	if [[ -n "$has_type3" ]]; then
		key="3_"
		key+=$(echo "$has_type3" | awk '{print $2"-"$4}')
	elif [[ -n "$has_type1" ]]; then
		key="1_"
		key+=$(echo "$has_type1" | awk '{print $2"-"$4}')
	fi
	
	if [[ -n "$has_type4" ]]; then
		[[ -n "$key" ]] && key+="%2"
		key+="_"
		key+=$(echo "$has_type4" | awk '{print $2}')
	elif [[ -n "$has_type2" ]]; then
		[[ -n "$key" ]] && key+="%2"
		key+="_"
		key+=$(echo "$has_type2" | awk '{print $2}')
	fi
	
	[[ -z "$key" ]] && key="unknown"
	echo "$key"
}

save_data_new() {
	local ip="$1"
	local whois_data="$2"
	local key=$(build_cache_key "$whois_data")
	local file="$DATADIR/${key}.txt"
	local dir=$(dirname "$file")
	local timestamp=$(date +%s)
	
	[[ ! -d "$dir" ]] && mkdir -p "$dir"
	
	cat > "$file" <<EOF
# IP: $ip
# KEY: $key
# TIMESTAMP: $timestamp
# TIMESTAMP_READABLE: $(date -d @$timestamp '+%Y-%m-%d %H:%M:%S')

$whois_data
EOF
	echo "New cache: $key"
}

#============================================================
# get_whois
#============================================================

get_whois() {
	local ip=$1
	echo "$ip" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$' && whois "$ip" 2>/dev/null
}

#============================================================
# MAIN
#============================================================

if [[ -z "$ARG_IP" ]]; then
	echo "Usage: $0 -i <ip> [-f] [-c]"
	echo "  -i, --ip: IP address"
	echo "  -f, --force: Force refresh"
	echo "  -c, --clear: Clear all cache"
	exit 1
fi

[[ "$ARG_CLEAR" == "true" ]] && rm -f "$DATADIR"/*.txt && echo "Cleared" && exit 0

if [[ "$ARG_FORCE" == "true" ]]; then
	data=$(get_whois "$ARG_IP")
	save_data "$ARG_IP" "$data"
	save_data_new "$ARG_IP" "$data"
	echo "$data"
	exit 0
fi

echo "Checking cache for $ARG_IP..."

data=$(load_data_new "$ARG_IP")
ret=$?

if [[ $ret -ne 0 || -z "$data" ]]; then
	data=$(load_data "$ARG_IP")
	ret=$?
fi

if [[ $ret -eq 0 && -n "$data" ]]; then
	echo "$data"
else
	data=$(get_whois "$ARG_IP")
	save_data "$ARG_IP" "$data"
	save_data_new "$ARG_IP" "$data"
	echo "$data"
fi