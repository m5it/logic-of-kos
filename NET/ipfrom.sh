#!/bin/bash
#
# Script to get IP geo info with caching using geoiplookup
# Uses ipis to determine range (with caching), geoiplookup for data
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
PCA=("IP" "FORCE" "CLEAR" "DEBUG")

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

ARG_DEBUG=false
DEBUG_SHORT_ARG="-d"
DEBUG_ARG="--debug"
DEBUG_VAL=false

source $PRE'src/pca.sh'

for arg in "$@"; do
	[[ ! "$arg" =~ ^- ]] && [[ -n "$arg" ]] && [[ "$IP_DEFAULT" == true ]] && [[ "$ARG_IP" == "" || "$ARG_IP" == "true" ]] && ARG_IP="$arg"
done

DATADIR="$D/NET/ipcome"
CACHE_DAYS=90  # 3 months

debug_echo() {
	[[ "$ARG_DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

mkdir -p "$DATADIR"

#============================================================
# Utility functions (imported from ipis)
#============================================================

ip_to_num() {
	local ip=$1
	local num=0
	IFS='.' read -ra octets <<< "$ip"
	for oct in "${octets[@]}"; do
		num=$((num * 256 + oct))
	done
	echo "$num"
}

#============================================================
# WHOIS-based range key (like ipis)
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
	
	key=$(echo "$key" | tr '/' '_')
	
	[[ -z "$key" ]] && key="unknown"
	echo "$key"
}

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
	
	sed '/^#/d' "$file"
	return 0
}

#============================================================
# NEW RANGE-BASED CACHING (from whois, like ipis)
#============================================================

save_data_new() {
	local ip="$1"
	local whois_data="$2"
	local geo_data="$3"
	local key=$(build_cache_key "$whois_data")
	local file="$DATADIR/${key}.txt"
	local timestamp=$(date +%s)
	
	cat > "$file" <<EOF
# IP: $ip
# KEY: $key
# TIMESTAMP: $timestamp
# TIMESTAMP_READABLE: $(date -d @$timestamp '+%Y-%m-%d %H:%M:%S')

$geo_data
EOF
	echo "New cache: $key"
}

load_data_new() {
	local ip=$1
	local ip_num=$(ip_to_num "$ip")
	local found_file=""
	
	while read -r cache_file; do
		[[ ! -f "$cache_file" ]] && continue
		
		local full_path=$(echo "$cache_file" | sed "s|$DATADIR/||")
		local key_name=$(basename "$cache_file" .txt)
		local range_match=$(echo "$key_name" | grep -oE '[13]_[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
		
		[[ -z "$range_match" ]] && continue
		
		local range_start=$(echo "$range_match" | cut -d'_' -f2 | cut -d'-' -f1)
		local suffix_part=$(echo "$key_name" | grep -oE '%.*$' | head -1)
		local range_prefix=24
		
		if [[ -n "$suffix_part" ]]; then
			range_prefix=$(echo "${suffix_part#*_}" | cut -d'/' -f2)
			[[ -z "$range_prefix" ]] && range_prefix=24
		fi
		
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

get_whois() {
	local ip=$1
	local script_path
	if [[ -L "$0" ]]; then
		script_path=$(realpath "$0")
	else
		script_path="$0"
	fi
	local script_dir=$(dirname "$script_path")
	local ipis_path="$(dirname "$script_dir")/NET/ipis.sh"
	local data
	debug_echo "get_whois: script_path=$script_path, script_dir=$script_dir, ipis_path=$ipis_path"
	if [[ -x "$ipis_path" ]]; then
		data=$("$ipis_path" "$ip" 2>/dev/null)
	else
		data=$(whois "$ip" 2>/dev/null)
	fi
	echo "$data" | grep -v "^Checking cache"
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

if [[ "$ARG_CLEAR" == "true" ]]; then
	rm -rf "$DATADIR"/*.txt
	echo "Cleared all cache"
	exit 0
fi

debug_echo "START: ARG_IP=$ARG_IP, ARG_FORCE=$ARG_FORCE, ARG_DEBUG=$ARG_DEBUG"

if [[ -z "$ARG_IP" ]]; then
	echo "Usage: $0 -i <ip> [-f] [-c]"
	echo "  -i, --ip: IP address"
	echo "  -f, --force: Force refresh"
	echo "  -c, --clear: Clear cached data"
	exit 1
fi

if [[ "$ARG_FORCE" == "true" ]]; then
	whois_data=$(get_whois "$ARG_IP")
	geo_data=$(get_geo "$ARG_IP")
	save_data "$ARG_IP" "$geo_data"
	save_data_new "$ARG_IP" "$whois_data" "$geo_data"
	echo "$geo_data"
	exit 0
fi

echo "Checking cache for $ARG_IP..."
debug_echo "Calling get_whois..."

whois_data=$(get_whois "$ARG_IP")
debug_echo "whois_data len=${#whois_data}"
key=$(build_cache_key "$whois_data")
debug_echo "key=$key"
cache_file="$DATADIR/${key}.txt"
debug_echo "cache_file=$cache_file, exists=$(test -f "$cache_file" && echo yes || echo no)"

if [[ -f "$cache_file" ]]; then
	debug_echo "Cache file exists, checking timestamp..."
	timestamp=$(grep "^# TIMESTAMP:" "$cache_file" | cut -d':' -f2 | tr -d ' ')
	now=$(date +%s)
	expiration=$((CACHE_DAYS * 24 * 60 * 60))
	debug_echo "timestamp=$timestamp, now=$now, expiration=$expiration"
	if [[ -n "$timestamp" && $((now - timestamp)) -lt $expiration ]]; then
		debug_echo "Using cached geo data"
		geo_data=$(sed '/^#/d' "$cache_file")
		echo "$geo_data"
		exit 0
	fi
fi

debug_echo "Fetching fresh geo data..."
geo_data=$(get_geo "$ARG_IP")
debug_echo "geo_data=$geo_data"
save_data "$ARG_IP" "$geo_data"
save_data_new "$ARG_IP" "$whois_data" "$geo_data"
echo "$geo_data"
exit 0