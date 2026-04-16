#!/bin/bash
#
# List virtual machines spawned with systemd-nspawn

command -v machinectl >/dev/null 2>&1 || { echo "machinectl not found. Install systemd-container package."; exit 1; }

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=true
PCA=("SIZE" "LOOP" "ALL")

ARG_SIZE=""
ARG_SIZE_STRING=false
SIZE_SHORT_ARG="-s"
SIZE_ARG="--size"
SIZE_VAL=false

ARG_LOOP=""
ARG_LOOP_STRING=false
LOOP_SHORT_ARG="-l"
LOOP_ARG="--loop"
LOOP_VAL=false

ARG_ALL=""
ARG_ALL_STRING=false
ALL_SHORT_ARG="-a"
ALL_ARG="--all"
ALL_VAL=false

source $PRE'src/pca.sh'

get_image_size() {
	local img="$1"
	local target=""
	local found=false
	
	for dir in "/var/lib/machines" "/var/lib/machines/img" "/home/chroots"; do
		if [[ -L "$dir/$img" ]]; then
			target=$(readlink -f "$dir/$img" 2>/dev/null)
			[[ -f "$target" ]] && found=true && break
		elif [[ -f "$dir/$img" ]]; then
			target="$dir/$img"
			found=true
			break
		fi
	done
	
	if ! $found; then
		for dir in "/var/lib/machines" "/var/lib/machines/img" "/home/chroots"; do
			if [[ -L "$dir/${img}.raw" ]]; then
				target=$(readlink -f "$dir/${img}.raw" 2>/dev/null)
				[[ -f "$target" ]] && found=true && break
			elif [[ -f "$dir/${img}.raw" ]]; then
				target="$dir/${img}.raw"
				found=true
				break
			fi
		done
	fi
	
	if $found && [[ -n "$target" && -f "$target" ]]; then
		ls -lh "$target" 2>/dev/null | awk '{print $5}'
		return
	fi
	
	echo "-"
}

get_loop_info() {
	local img="$1"
	local target=""
	local found=false
	
	for dir in "/var/lib/machines" "/var/lib/machines/img" "/home/chroots"; do
		if [[ -L "$dir/$img" ]]; then
			target=$(readlink -f "$dir/$img" 2>/dev/null)
			[[ -f "$target" ]] && found=true && break
		elif [[ -f "$dir/$img" ]]; then
			target="$dir/$img"
			found=true
			break
		fi
	done
	
	if ! $found; then
		for dir in "/var/lib/machines" "/var/lib/machines/img" "/home/chroots"; do
			if [[ -L "$dir/${img}.raw" ]]; then
				target=$(readlink -f "$dir/${img}.raw" 2>/dev/null)
				[[ -f "$target" ]] && found=true && break
			elif [[ -f "$dir/${img}.raw" ]]; then
				target="$dir/${img}.raw"
				found=true
				break
			fi
		done
	fi
	
	if $found && [[ -n "$target" ]]; then
		if command -v losetup >/dev/null 2>&1; then
			sudo losetup -j "$target" 2>/dev/null | awk '{print $1}' | sed 's/.*loop//' | sed 's/:.*//' | while read -r dev; do
				[[ -n "$dev" ]] && echo "/dev/loop$dev $target"
			done
			[[ -z "$(sudo losetup -j "$target" 2>/dev/null)" ]] && echo "- $target"
		else
			echo "- $target"
		fi
		return
	fi
	
	echo "- -"
}

SHOW_SIZE=false
SHOW_LOOP=false

[[ "$ARG_SIZE" == "true" ]] && SHOW_SIZE=true
[[ "$ARG_LOOP" == "true" ]] && SHOW_LOOP=true
[[ "$ARG_ALL" == "true" ]] && SHOW_SIZE=true && SHOW_LOOP=true

if $SHOW_SIZE && $SHOW_LOOP; then
	while read -r line; do
		[[ -z "$line" ]] && continue
		img=$(echo "$line" | awk '{print $1}')
		size=$(get_image_size "$img")
		loop_info=$(get_loop_info "$img")
		echo "$line $size $loop_info"
	done < <(machinectl list --no-legend)
elif $SHOW_LOOP; then
	while read -r line; do
		[[ -z "$line" ]] && continue
		img=$(echo "$line" | awk '{print $1}')
		loop_info=$(get_loop_info "$img")
		echo "$line $loop_info"
	done < <(machinectl list --no-legend)
elif $SHOW_SIZE; then
	while read -r line; do
		[[ -z "$line" ]] && continue
		img=$(echo "$line" | awk '{print $1}')
		size=$(get_image_size "$img")
		echo "$line $size"
	done < <(machinectl list --no-legend)
else
	machinectl list --no-legend
fi
