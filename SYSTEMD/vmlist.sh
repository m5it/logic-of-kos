#!/bin/bash
#
# List virtual machines spawned with systemd-nspawn

command -v machinectl >/dev/null 2>&1 || { echo "machinectl not found. Install systemd-container package."; exit 1; }

MACHINE_DIR="/var/lib/machines"

get_image_size() {
	local img="$1"
	local target
	
	if [[ -L "$MACHINE_DIR/$img" ]]; then
		target=$(readlink -f "$MACHINE_DIR/$img" 2>/dev/null)
		if [[ -e "$target" ]]; then
			ls -lh "$target" 2>/dev/null | awk '{print $5}'
			return
		fi
	fi
	echo "-"
}

if [[ "$1" == "-s" || "$1" == "--size" ]]; then
	while read -r line; do
		[[ -z "$line" ]] && continue
		img=$(echo "$line" | awk '{print $1}')
		size=$(get_image_size "$img")
		echo "$line $size"
	done < <(machinectl list --no-legend)
else
	machinectl list --no-legend
fi
