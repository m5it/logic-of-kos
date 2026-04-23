#!/bin/bash
#

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=true
PCA=("NAME" "SIZE" "TYPE" "FORMAT" "YES" "DEBUG")

ARG_NAME=""
ARG_NAME_STRING=true
NAME_SHORT_ARG="-n"
NAME_ARG="--name"
NAME_VAL=true

ARG_SIZE=""
ARG_SIZE_STRING=true
SIZE_SHORT_ARG="-s"
SIZE_ARG="--size"
SIZE_VAL=true

ARG_TYPE=""
ARG_TYPE_STRING=true
TYPE_SHORT_ARG="-t"
TYPE_ARG="--type"
TYPE_VAL=true

ARG_FORMAT=""
ARG_FORMAT_STRING=true
FORMAT_SHORT_ARG="-f"
FORMAT_ARG="--format"
FORMAT_VAL=true

ARG_YES=""
ARG_YES_STRING=false
YES_SHORT_ARG="-Y"
YES_ARG="--yes"
YES_VAL=false

ARG_DEBUG=false
DEBUG_SHORT_ARG="-d"
DEBUG_ARG="--debug"
DEBUG_VAL=false

source $PRE'src/pca.sh'

debug_echo() {
	[[ "$ARG_DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

check_command() {
	local cmd="$1"
	local pkg="$2"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "ERROR: $cmd not found."
		echo "Install $pkg package:"
		echo "  sudo apt install $pkg"
		return 1
	fi
	return 0
}

check_required_commands() {
	local type="${ARG_TYPE:-raw}"
	local fmt="${FORMAT:-ext4}"
	local errors=0
	
	if ! check_command "dd" "coreutils"; then ((errors++)); fi
	
	if [[ "$type" == "qcow2" ]]; then
		if ! check_command "qemu-img" "qemu-utils"; then ((errors++)); fi
	fi
	
	if [[ "$fmt" != "none" ]]; then
		if [[ "$fmt" == "ext4" ]]; then
			if ! check_command "mkfs.ext4" "e2fsprogs"; then ((errors++)); fi
		elif [[ "$fmt" == "xfs" ]]; then
			if ! check_command "mkfs.xfs" "xfsprogs"; then ((errors++)); fi
		elif [[ "$fmt" == "btrfs" ]]; then
			if ! check_command "mkfs.btrfs" "btrfs-progs"; then ((errors++)); fi
		else
			echo "ERROR: Unknown format: $fmt"
			((errors++))
		fi
	fi
	
	return $errors
}

NAME="${ARG_NAME}"
SIZE="${ARG_SIZE:-10240}"  # Default 10GB
TYPE="${ARG_TYPE:-raw}"      # Default raw
FORMAT="${ARG_FORMAT:-ext4}"  # Default ext4 filesystem
YES="${ARG_YES:-false}"

check_disk_space() {
	local required_mb=$1
	local target_dir="${2:-.}"
	
	local available_bytes=$(df -B1 "$target_dir" 2>/dev/null | awk 'NR==2 {print $4}')
	local available_mb=$((available_bytes / 1024 / 1024))
	
	debug_echo "Required: ${required_mb}MB, Available: ${available_mb}MB"
	
	if [[ $available_mb -lt $required_mb ]]; then
		echo "ERROR: Not enough disk space!"
		echo "  Required: ${required_mb}MB"
		echo "  Available: ${available_mb}MB"
		return 1
	fi
	return 0
}

create_image_raw() {
	local name="$1"
	local size_mb="$2"
	debug_echo "Creating raw image: $name (${size_mb}MB)"
	dd if=/dev/zero of="$name" bs=1M count="$size_mb" status=progress
	sync
}

create_image_qcow2() {
	local name="$1"
	local size_gb="$2"
	debug_echo "Creating qcow2 image: $name (${size_gb}GB)"
	qemu-img create -f qcow2 -o preallocation=metadata "$name" "${size_gb}G"
}

if [[ "$NAME" == "" ]]; then
	echo "Usage: $0 -n <name> [-s <size_mb>] [-t <type>] [-f <format>]"
	echo "  -n, --name: VM name (e.g. myvm.raw)"
	echo "  -s, --size: Size in MB (default: 10240 = 10GB)"
	echo "  -t, --type: Image type: raw, qcow2 (default: raw)"
	echo "  -f, --format: Filesystem: ext4, xfs, btrfs, none (default: ext4)"
	exit 1
fi

# Auto-detect type from extension
if [[ -z "$ARG_TYPE" ]]; then
	case "$NAME" in
		*.qcow2) TYPE="qcow2" ;;
		*.raw|*.img|*) TYPE="raw" ;;
	esac
fi

check_required_commands || exit 1

size_gb=$((SIZE / 1024))
[[ $size_gb -lt 1 ]] && size_gb=1

if ! check_disk_space $((SIZE + 512)) "." 2>/dev/null; then
	exit 1
fi

debug_echo "Creating VM '$NAME' with size ${SIZE}MB (type: $TYPE)"

if [[ "$YES" != "true" ]]; then
	echo "Creating: $NAME, size: ${SIZE}MB, type: $TYPE"
	echo "Sleep 3s..."
	sleep 3
fi

if [[ "$TYPE" == "qcow2" ]]; then
	create_image_qcow2 "$NAME" "$size_gb"
else
	create_image_raw "$NAME" "$SIZE"
fi

# Create filesystem if format is specified
if [[ "$FORMAT" != "none" ]]; then
	echo "Creating filesystem: $FORMAT"
	mkfs.$FORMAT -F "$NAME"
fi

echo "Done: $NAME created"