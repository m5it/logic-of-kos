#!/bin/bash

# Mirror two directories using rsync
# Usage: mirdir.sh -s <source> -d <destination>

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA=("SOURCE" "DESTINATION")
PCA_ON_NONE_HELP=true

ARG_SOURCE=""
ARG_SOURCE_STRING=true
SOURCE_SHORT_ARG="-s"
SOURCE_ARG="--source"
SOURCE_VAL=true

ARG_DESTINATION=""
ARG_DESTINATION_STRING=true
DESTINATION_SHORT_ARG="-d"
DESTINATION_ARG="--destination"
DESTINATION_VAL=true

source $PRE'src/pca.sh'

[[ -z "$ARG_SOURCE" && -n "$1" && "$1" != -* ]] && ARG_SOURCE="$1"
[[ -z "$ARG_DESTINATION" && -n "$2" && "$2" != -* ]] && ARG_DESTINATION="$2"

SRC="$ARG_SOURCE"
DST="$ARG_DESTINATION"

# Validate source directory
if [ ! -d "$SRC" ]; then
    echo "Error: Source directory '$SRC' does not exist or is not a directory."
    exit 1
fi

# Create destination directory if it doesn't exist
if [ ! -d "$DST" ]; then
    echo "Creating destination directory: $DST"
    mkdir -p "$DST"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create destination directory '$DST'."
        exit 1
    fi
fi

# Perform mirroring with rsync
echo "Mirroring '$SRC' to '$DST'..."
rsync -av --delete "$SRC"/ "$DST"/

# Exit with the same status code as rsync
exit $?