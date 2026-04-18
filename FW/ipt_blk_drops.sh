#!/bin/bash
#
# Script to DROP ips or ranges defined in dropped.txt

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
	echo "Create it with: ipt_gen_drops"
	exit 1
fi

debug_echo "Using drop file: $DROPFILE"

count=0
while read -r src; do
	[[ -z "$src" || "$src" =~ ^# ]] && continue
	debug_echo "Blocking: $src"
	iptables -A INPUT $src -j DROP
	((count++))
done < "$DROPFILE"

echo "Done. Blocked $count entries from $DROPFILE"