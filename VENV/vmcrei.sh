#!/bin/bash
#

SIZE=$((5 * 10240)) # Gb
NAME="gits.raw"

echo "Using size: "$SIZE
sleep 5

dd if=/dev/zero of=$NAME bs=1M count=$SIZE status=progress;sync

gdisk -l $NAME

mkfs.ext4 -F $NAME
mkdir $NAME".mount"
mount -t ext4 $NAME $NAME".mount"

echo "Image: "$NAME" mounted at "$NAME".mount"
