#!/bin/bash

if [[ -t 0 ]]; then
	echo "Not piped!"
else
	echo "Piped!"
fi
