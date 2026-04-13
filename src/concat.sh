#!/bin/bash
# Configuration
CONCAT_FILE="$D/.concat_lines.tmp"
ORIGINAL_FILE="$D/.original_lines.tmp"
# Function to concatenate lines into one line
concat_lines() {
	local input_file="$1"
	if [ ! -f "$input_file" ]; then
		echo "Error: File $input_file does not exist."
		return 1
	fi
	local delimiter="|"
	local tmp=$(tr '\n' '|' < "$input_file" | sed 's/|$//')
	echo "$tmp"
}
 
# Function to restore lines from concatenated format
restore_lines() {
	local tmp="$*"
	local delimiter="|"
	echo "$tmp" | tr "$delimiter" "\n"
}
