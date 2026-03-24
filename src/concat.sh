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
	# Read all lines and join them with a special delimiter
	# Using a unique delimiter that shouldn't appear in the content
	local delimiter="\x10"
	local concatenated=$(paste -sd "$delimiter" "$input_file")
	echo "$concatenated"
}
 
# Function to restore lines from concatenated format
restore_lines() {
	local concatenated=$*
	local delimiter="\x10"
	echo "$concatenated" | tr "$delimiter" "\n"
}
