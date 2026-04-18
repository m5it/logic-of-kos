#!/bin/bash
#

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=true
PCA=("NAME" "SIZE" "TYPE" "DEBUG")

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
	local errors=0
	
	debug_echo "Checking required commands for type: $type"
	
	if ! check_command "dd" "coreutils"; then ((errors++)); fi
	
	if [[ "$type" == "qcow2" ]]; then
		if ! check_command "qemu-img" "qemu-utils"; then ((errors++)); fi
	else
		if ! check_command "gdisk" "gdisk"; then ((errors++)); fi
		if ! check_command "mkfs.ext4" "e2fsprogs"; then ((errors++)); fi
		if ! check_command "mount" "mount"; then ((errors++)); fi
	fi
	
	return $errors
}

NAME="${ARG_NAME}"
SIZE="${ARG_SIZE:-10240}"  # Default 10GB
TYPE="${ARG_TYPE:-raw}"      # Default raw

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
	echo "Usage: $0 -n <name> [-s <size_mb>] [-t <type>]"
	echo "  -n, --name: VM name (e.g. myvm.raw or myvm.qcow2)"
	echo "  -s, --size: Size in MB (default: 10240 = 10GB)"
	echo "  -t, --type: Image type: raw or qcow2 (default: raw)"
	exit 1
fi

# Auto-detect type from extension if not specified
if [[ -z "$ARG_TYPE" ]]; then
	case "$NAME" in
		*.qcow2|*.qcow2) TYPE="qcow2" ;;
		*.raw|*.img|*) TYPE="raw" ;;
	esac
fi

debug_echo "Using type: $TYPE"

check_required_commands || exit 1

size_gb=$((SIZE / 1024))
[[ $size_gb -lt 1 ]] && size_gb=1

if ! check_disk_space $((SIZE + 512)) "." 2>/dev/null; then
	exit 1
fi

debug_echo "Creating VM '$NAME' with size ${SIZE}MB (type: $TYPE)"

echo "Creating: $NAME, size: ${SIZE}MB, type: $TYPE"
echo "Sleep 3s..."
sleep 3

if [[ "$TYPE" == "qcow2" ]]; then
	create_image_qcow2 "$NAME" "$size_gb"
else
	create_image_raw "$NAME" "$SIZE"
fi

echo "Done: $NAME created"