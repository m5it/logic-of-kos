#!/bin/bash
# Check and repair filesystem on VM image using e2fsck

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=true
PCA=("IMAGE" "YES")

ARG_IMAGE=""
ARG_IMAGE_STRING=true
IMAGE_SHORT_ARG="-i"
IMAGE_ARG="--image"
IMAGE_VAL=true

ARG_YES=""
ARG_YES_STRING=false
YES_SHORT_ARG="-Y"
YES_ARG="--yes"
YES_VAL=false

source $PRE'src/pca.sh'

IMAGE="${ARG_IMAGE}"
YES="${ARG_YES:-false}"

if [[ -z "$IMAGE" ]]; then
	echo "Usage: $0 -i <image_file> [-Y]"
	echo "  -i, --image   Path to VM image file (e.g. test.raw)"
	echo "  -Y, --yes     Skip all confirmation prompts"
	exit 1
fi

if [[ ! -f "$IMAGE" ]]; then
	echo "ERROR: Image file not found: $IMAGE"
	echo "  Use -h for help"
	exit 1
fi

# Check if image already has a loop device
LOOP=$(losetup -l 2>/dev/null | awk -v img="$IMAGE" '$0 ~ img {print $1}')

if [[ -n "$LOOP" ]]; then
	echo "Image already has loop device: $LOOP"
else
	if [[ "$YES" != "true" ]]; then
		echo "Run e2fsck on: $IMAGE"
		echo "Continue? (Y/n)"
		read TMP
		[[ "$TMP" != "Y" ]] && { echo "Exiting"; exit 1; }
	fi
	losetup -fP "$IMAGE" || { echo "ERROR: Failed to set up loop device for $IMAGE"; exit 1; }
	LOOP=$(losetup -l 2>/dev/null | awk -v img="$IMAGE" '$0 ~ img {print $1}')
	echo "Got loop: $LOOP"
fi

if [[ -z "$LOOP" ]]; then
	echo "ERROR: Could not determine loop device for $IMAGE"
	exit 1
fi

echo "Running e2fsck on $LOOP..."
e2fsck -f -y "$LOOP"

echo "Detach loop device $LOOP? (Y/n)"
if [[ "$YES" != "true" ]]; then
	read TMP
	[[ "$TMP" != "Y" ]] && { echo "Loop $LOOP left attached"; exit 0; }
fi

losetup -d "$LOOP" && echo "Loop $LOOP detached"
