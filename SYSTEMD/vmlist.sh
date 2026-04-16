#!/bin/bash
#
# List virtual machines spawned with systemd-nspawn

command -v machinectl >/dev/null 2>&1 || { echo "machinectl not found. Install systemd-container package."; exit 1; }

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
		losetup -l 2>/dev/null | grep "$target" | awk '{print $1, $5}'
		return
	fi
	
	echo "- -"
}

SHOW_SIZE=false
SHOW_LOOP=false

for arg in "$@"; do
	case "$arg" in
		-s|--size) SHOW_SIZE=true ;;
		-l|--loop) SHOW_LOOP=true ;;
		-a|--all) SHOW_SIZE=true; SHOW_LOOP=true ;;
	esac
done

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
