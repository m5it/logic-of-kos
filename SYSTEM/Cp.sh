#!/bin/bash
#
# rsync refs:
#   https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories
#--
# Just display action:
# --dry-run OR -n
# Other interesting options:
# -v (verbose)
# -vv (more verbose)
#--
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/../"
source $PRE'prepare.sh' # include prepared global variables like: realpath, filenick, filename..

#--
# Define variables for pca.sh ( parse command line arguments )
#--
# Display help if no args set...
PCA_ON_NONE_HELP=false

# Define array of available argument options
PCA=("PROGRESS")
#
ARG_PROGRESS=""
#
PROGRESS_SHORT_ARG="-p"
PROGRESS_ARG="--progress"
PROGRESS_VAL=false

#--
# Parse command line arguments
source $PRE'pca.sh'
#
CMDS=""
#
let IFF=NPCA+1
let IFT=NPCA+2
FROM=${!IFF}
TO=${!IFT}
#
# rsync -a --progress kosgen/usr/portage/chroot_x86-64/usr/portage/bins t3ch/dff8102e-57ac-4fea-95a9-82c86278ee20/gentoo/bins
#
echo "DEBUG ARGS( "$APCA"|"$NPCA" ): "
echo "PROGRESS: "$ARG_PROGRESS
echo "FROM: "$FROM
echo "TO:   "$TO
# to skip existing:
# --ignore-existing
# --update
#
#--
# MAIN
#
if [[ $ARG_PROGRESS == true ]]; then
	echo "Going to sync dirs from "$FROM" to "$TO
	source $PRE'continue.sh'
	rsync -a --progress $FROM $TO
else
	echo "Going to sync dirs from "$FROM" to "$TO
	source $PRE'continue.sh'
	rsync -a $FROM $TO
fi
