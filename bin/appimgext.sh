#!/bin/bash

if [[ "$1" == "" ]]; then
	echo "Usage "$0" someAppImageToExtract.AppImage"
	exit
fi

./$1 --appimage-extract
