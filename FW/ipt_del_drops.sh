#!/bin/bash
#
# Script to DELETE (remove) ips or ranges from iptables that are in dropped.txt

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("FILE" "DEBUG")

ARG_FILE=""
ARG_FILE_STRING=true
FILE_SHORT_ARG="-f"
FILE_ARG="--file"
FILE_VAL=true

ARG_DEBUG=false
DEBUG_SHORT_ARG="-d"
DEBUG_ARG="--debug"
DEBUG_VAL=false

source $PRE'src/pca.sh'

debug_echo() {
	[[ "$ARG_DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

DROPFILE="${ARG_FILE:-$D/FW/dropped.txt}"

if [[ ! -f "$DROPFILE" ]]; then
	echo "ERROR: Drop file not found: $DROPFILE"
	exit 1
fi

debug_echo "Using drop file: $DROPFILE"

count=0
while read -r src; do
	[[ -z "$src" || "$src" =~ ^# ]] && continue
	debug_echo "Removing block: $src"
	iptables -D INPUT $src -j DROP 2>/dev/null
	((count++))
done < "$DROPFILE"

echo "Done. Removed $count entries from iptables"