#!/bin/bash
#
# Script to generate ips and ip ranges that are DROPed with iptables
# and save them to ~/.config/lok/FW/dropped.txt

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("OUTPUT" "DEBUG")

ARG_OUTPUT=""
ARG_OUTPUT_STRING=true
OUTPUT_SHORT_ARG="-o"
OUTPUT_ARG="--output"
OUTPUT_VAL=true

ARG_DEBUG=false
DEBUG_SHORT_ARG="-d"
DEBUG_ARG="--debug"
DEBUG_VAL=false

source $PRE'src/pca.sh'

debug_echo() {
	[[ "$ARG_DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

DROPFILE="${ARG_OUTPUT:-$D/FW/dropped.txt}"

mkdir -p "$(dirname "$DROPFILE")"

debug_echo "Generating dropped IPs to: $DROPFILE"

iptables -L -n 2>/dev/null | awk '!/range/ && /DROP/{print "-s "$4}' > "$DROPFILE"
iptables -L -n 2>/dev/null | awk '/range/ && /DROP/ {print "-m iprange --src-range "$9}' >> "$DROPFILE"

n=$(grep -v '^#' "$DROPFILE" | grep -v '^$' | wc -l)
echo "Done. Saved $n entries to $DROPFILE"