#!/bin/bash
#
# Start systemd-nspawn container with various options
# Supports: KVM, NVIDIA, standard containers

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=true
PCA=("IMAGE" "DIRECTORY" "VFB" "YES")

ARG_IMAGE=""
ARG_IMAGE_STRING=true
IMAGE_SHORT_ARG="-i"
IMAGE_ARG="--image"
IMAGE_VAL=true

ARG_DIRECTORY=""
ARG_DIRECTORY_STRING=true
DIRECTORY_SHORT_ARG="-D"
DIRECTORY_ARG="--directory"
DIRECTORY_VAL=true

ARG_VFB=""
ARG_VFB_STRING=true
VFB_SHORT_ARG="-v"
VFB_ARG="--vfb"
VFB_VAL=true

ARG_YES=""
ARG_YES_STRING=false
YES_SHORT_ARG="-Y"
YES_ARG="--yes"
YES_VAL=false

source $PRE'src/pca.sh'

debug_echo() {
	[[ "$ARG_DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

IMAGE="${ARG_IMAGE}"
DIRECTORY="${ARG_DIRECTORY}"
VFB="${ARG_VFB}"
YES="${ARG_YES:-false}"

# Build command
if [[ -n "$DIRECTORY" ]]; then
	CMD="-D $DIRECTORY"
else
	CMD="--image $IMAGE"
fi

# Video Framebuffer options
if [[ "$VFB" == "KVM" || "$VFB" == "NVIDIA" ]]; then
	CMD="$CMD --bind=/dev/kvm --bind=/dev/pts --bind=/dev/dri --bind=/dev/input --bind=/dev/shm"
	if [[ "$VFB" == "NVIDIA" ]]; then
		CMD="$CMD --bind=/dev/nvidia-modeset --bind=/dev/nvidia-uvm --bind=/dev/nvidia-uvm-tools --bind=/dev/nvidia0 --bind=/dev/nvidiactl"
		CMD="$CMD --bind=/usr/lib/nvidia --bind=/usr/src/nvidia-590.48.01 --bind=/etc/ld.so.conf.d/libc.conf"
		CMD="$CMD --bind=/etc/ld.so.conf.d/x86_64-linux-gnu.conf --bind=/lib/modules/6.17.0-14-generic --bind=/sys/module"
	fi
	CMD="$CMD -u root --network-veth"
else
	CMD="$CMD --network-veth -U"
fi

debug_echo "CMD: $CMD"

if [[ "$YES" != "true" ]]; then
	echo "Spawning CMD: $CMD"
	echo "VFB: $VFB. Continue? (Y/n)"
	read TMP
	if [[ "$TMP" != "Y" ]]; then
		echo "Exiting..."
		exit 1
	fi
fi

echo "Spawning..."
systemd-nspawn --quiet --boot $CMD
