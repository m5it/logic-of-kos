#!/bin/bash
#
# LOK Framework: history.sh
# Reusable history logging functionality
#
# Usage:
#   source history.sh
#   history_init "program_name"
#   history_add "command data"
#   history_list [N]
#   history_get N
#

HISTORY_ENABLED=true
HISTORY_DIR=""
HISTORY_FILE=""
HIST_PROG=""

history_init() {
	local prog=$1
	HIST_PROG=$prog
	
	if [[ -z "$DH" ]]; then
		local _src="${BASH_SOURCE[0]}"
		local _dir="$(cd "$(dirname "${_src}")" && pwd)"
		PRE="$(cd "${_dir}/.." && pwd)/"
		source $PRE'src/prepare.sh'
	fi
	
	HISTORY_DIR="$DH/$prog"
	HISTORY_FILE="$HISTORY_DIR/history.log"
	
	if [[ ! -d "$HISTORY_DIR" ]]; then
		if ! mkdir -p "$HISTORY_DIR"; then
			echo "Failed creating $HISTORY_DIR, check permissions!"
			return 1
		fi
	fi
}

history_add() {
	if [[ "$HISTORY_ENABLED" != "true" ]]; then
		return
	fi
	
	if [[ -z "$HISTORY_FILE" ]]; then
		echo "Error: history not initialized. Call history_init first." >&2
		return 1
	fi
	
	local tmpdata
	tmpdata="$(get_datetime) | $1"
	echo "$tmpdata" >> "$HISTORY_FILE"
}

history_list() {
	if [[ -z "$HISTORY_FILE" ]]; then
		echo "Error: history not initialized. Call history_init first."
		return 1
	fi
	
	if [[ ! -f "$HISTORY_FILE" ]]; then
		echo "History does not exist."
		return 1
	fi
	
	if [[ -n "$1" ]]; then
		tail -n "$1" "$HISTORY_FILE" | nl -v 1
	else
		cat "$HISTORY_FILE" | nl -v 1
	fi
}

history_get() {
	if [[ -z "$HISTORY_FILE" ]]; then
		echo "Error: history not initialized. Call history_init first."
		return 1
	fi
	
	if [[ ! -f "$HISTORY_FILE" ]]; then
		echo "History does not exist."
		return 1
	fi
	
	local line=$(sed -n ${1}'p' "$HISTORY_FILE")
	echo "$line"
}

history_enable() {
	HISTORY_ENABLED=true
}

history_disable() {
	HISTORY_ENABLED=false
}