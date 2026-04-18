#!/bin/bash
#
# lsh - show hidden files (like ls -a | grep ^\\..*)

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("PATH" "DEBUG")

ARG_PATH=""
ARG_PATH_STRING=true
PATH_SHORT_ARG="-p"
PATH_ARG="--path"
PATH_VAL=true

ARG_DEBUG=false
DEBUG_SHORT_ARG="-d"
DEBUG_ARG="--debug"
DEBUG_VAL=false

source $PRE'src/pca.sh'

debug_echo() {
	[[ "$ARG_DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

TARGET="${ARG_PATH:-.}"

debug_echo "Listing hidden files in: $TARGET"

ls -a "$TARGET" | grep '^\.'