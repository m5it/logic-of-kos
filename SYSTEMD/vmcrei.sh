#!/bin/bash
#

#SIZE=$((5 * 10240)) # Gb
#NAME="gits.raw"
NAME=$1
SIZE=10240  # 10240 = 10Gb
#
if [[ "$NAME" == "" ]]; then
	echo "Usage: "$0" machine.name "$SIZE
	exit 1
fi
#
if [[ "$2" != "" ]]; then
	SIZE=$2
fi
echo "Using name: "$NAME", size: "$SIZE"... Sleep 5s"
sleep 5

dd if=/dev/zero of=$NAME bs=1M count=$SIZE status=progress;sync

gdisk -l $NAME

mkfs.ext4 -F $NAME
mkdir $NAME".mount"
mount -t ext4 $NAME $NAME".mount"

echo "Image: "$NAME" mounted at "$NAME".mount"
