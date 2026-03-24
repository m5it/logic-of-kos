#!/bin/bash
#
# LOK Framework: prepare.sh, continue.sh, isadmin.sh, pca.sh
#
#--
#echo "0: "$0
#echo "real 0: "$(realpath $0)
U=$(realpath $0)
#U=$(echo $U | sed "s/\//\x5C\//g")
#B=$(basename $0 | sed 's/\.sh$//g')
B=$(basename $(realpath $0) | sed 's/\.sh$//g')
P=$(dirname $U | sed 's/^\.\///g') # basename, realpath, dirname
#V=$(cat $P'/'$PRE'version.txk' | sed "s/\[\-\-\#SCRIPT\_NAME\#\-\-\]/"$B"/g")
V=$(cat $PRE'version.txk' | sed "s/\[\-\-\#SCRIPT\_NAME\#\-\-\]/"$B"/g")
H=$(echo -n $B | sed 's/\.sh$//g' | (echo -n "help_for_" && cat) | (echo -n $P"/" && cat) | sed 's/$/.txk/')
D=$HOME"/.config/lok"
DL=$D"/live"
DS=$D"/saves"
DH=$D"/history"
#--
#
# Usage:
#     Set a value
#     config_set "MY_KEY" "My Value"
# v = config_get "MY_KEY"
# echo "Value: "$v
#CONFIG_FILE=$P"/src/lok.conf"
CONFIG_FILE="$D/lok.conf"
#echo "DEBUG config.sh => Start, CONFIG_FILE: "$CONFIG_FILE

if [[ -n "$DEBUG" ]]; then
	echo "DEBUG prepare.sh => CONFIG_FILE: "$CONFIG_FILE
	echo "DEBUG prepare.sh => homedir: "$HOME
	echo "DEBUG prepare.sh => PRE: "$PRE
	echo "DEBUG prepare.sh => U: "$U
	echo "DEBUG prepare.sh => B: "$B
	echo "DEBUG prepare.sh => P: "$P
	echo "DEBUG prepare.sh => V: "$V
	echo "DEBUG prepare.sh => H: "$H
	echo "DEBUG prepare.sh => D: "$D
	echo "DEBUG prepare.sh => DL: "$DL
	echo "DEBUG prepare.sh => DS: "$DS
	echo "DEBUG prepare.sh => DH: "$DH
fi
#-- Functions
# additional functions
source $PRE"src/concat.sh"

#
strip_file_type() {
	local file=$1
	IFS='.' read -r -a arr <<< "$file"
	#echo "test arr: "${arr[-2]}
	CNT=1
	for chunk in ${arr[@]}; do
		echo $chunk
		CNT=$((CNT += 1))
		if [[ $CNT -ge ${#arr[@]} ]]; then
			break
		else
			echo "."
		fi
	done
}

#
print_array() {
	local arr=$1
	for line in ${arr[@]}; do
		echo $line
	done
}

# Usage: 
#   in_array "cputemp" "${elms[@]}"
in_array() {
	local value=$1
	shift
	local array=("$@")
	i=0
	echo "in_array() START, array: ${array[@]}, value: $value"
 
	for val in "${array[@]}"; do
		echo "in_array val: $val"
		if [[ "$val" == "$value" ]]; then
			echo "Value '$value' found in array"
			return $i
		fi
		i=$((i+1))
	done
 
	echo "Value '$value' not found in array"
	return -1
}
#
get_datetime() {
    date "+%Y-%m-%d %H:%M:%S"
}
#
get_timestamp_ms() {
    # Using date command with nanoseconds and converting to milliseconds
    local timestamp=$(date +%s%3N)
    echo "$timestamp"
}
 
# Function to get current timestamp in seconds
get_timestamp_s() {
    # Using date command with seconds
    local timestamp=$(date +%s)
    echo "$timestamp"
}
#-- Set key:value / Get data by key
# data_get "somefile" "key"
data_get() {
	local file=$1
	local key=$2
	if [[ "$file" == "" ]]; then
		echo "Failed: data_get() Missing argument 1 as filename"
		exit 1
	fi
	#file=$D"/"$file
	local value=$(grep "^$key:" "$file" | cut -d':' -f2-)
	echo "$value"
}

# data_set "somefile" "key" "value"
data_set() {
	local file=$1
	local key=$2
	local value=$3
	if [[ "$file" == "" ]]; then
		echo "Failed: data_set() Missing argument 1 as filename"
		exit 1
	fi
	# check if dir exists
	tmpd=$(dirname $file)
	if [[ ! -d "$tmpd" ]]; then
		if ! mkdir -p "$tmpd"; then
			echo "ERROR: data_set() Creating directory "$tmpd
			exit 1
		fi
	fi
	echo "file: "$file
	echo "tmpd: "$tmpd
	#file=$D"/"$file
	if [[ -f "$file" ]]; then
		echo "d1"
		# Create a temporary file
		local tmp_file=$(mktemp)
		local WAS_ADDED=false
		# Process the original file
		while IFS= read -r line; do
			#echo "d1 line "$line
			# If the line starts with the key, replace it with the new value
			if [[ "$line" =~ ^$key: ]]; then
				#echo "d1 adding d1, "$tmp_file
				echo "$key:$value" >> "$tmp_file"
				WAS_ADDED=true
			else
				#echo "d1 adding d2, "$tmp_file
				echo "$line" >> "$tmp_file"
			fi
		done < "$file"
		#
		if [[ $WAS_ADDED == false ]]; then
			#echo "d1 adding d3, "$tmp_file
			echo "$key:$value" >> "$tmp_file"
		fi
		# Replace the original file with the temporary file
		mv "$tmp_file" "$file"
	else
		#echo "d2"
		echo "$key:$value" >> "$file"
	fi
}
#
data_clear() {
	local file=$1
	if [[ "$file" == "" ]]; then
		echo "Failed: data_clear() Missing argument 1 as filename"
		exit 1
	fi
	#tmpfile=$D"/"$file
	#mv $file $(dirname $file)"/deleted_"$(get_timestamp_ms)"_"$(basename $file)
	if [[ ! -f "$file" ]]; then
		echo "Error: data_clear() Missing file "$file
		exit 1
	fi
	tmpd=$(dirname $file)
	tmpf=$(basename $file)
	# backup
	if ! mv $file $tmpd"/backup_"$(get_timestamp_ms)"_"$tmpf; then
		echo "Failed: data_clear() Backing up "$file
		exit 1
	fi
	# clear
	#if ! echo "" > "$file"; then
	#	echo "Failed: data_clear() Clearing file "$file
	#	exit 1
	#fi
	echo "Success: data_clear()!"
}
#--
# Prepare .config/lok/ directories
# 1.) Check if ~/.config exists then lets create ~/.config/lok
if [[ ! -d "$D" ]]; then
	if ! mkdir -p "$D"; then
		echo "ERROR creating lok directory! Check permissions for $D."
	fi
fi
#
if [[ ! -d "$DL" ]]; then
	if ! mkdir -p "$DL"; then
		echo "ERROR creating live directory! Check permissions for $DL."
	fi
fi
#
if [[ ! -d "$DS" ]]; then
	if ! mkdir -p "$DS"; then
		echo "ERROR creating live directory! Check permissions for $DS."
	fi
fi
#
if [[ ! -d "$DH" ]]; then
	if ! mkdir -p "$DH"; then
		echo "ERROR creating live directory! Check permissions for $DH."
	fi
fi
##--
## test data_set, data_get
#data_set $D"/live/SYSTEMD/test.txt" "key1" "value 123"
#data_set $D"/live/SYSTEMD/test.txt" "key2" "value 321"
#tmp=$(data_get $D"/live/SYSTEMD/test.txt" "key2")
#echo "debug tmp of key2: "$tmp
###--
#tmp=$(concat_lines $D"/live/SYSTEMD/test.txt")
#tsms=$(get_timestamp_ms)
#key="save_"$tsms
#echo "concated( "$key" ): "$tmp
##data_set $D"/saves/test.txt" $key "$tmp"
##tmp=$(data_get $D"/saves/test.txt" $key)
#echo "restoring( "$key" ): "$tmp
#restore_lines "$tmp"
###--
###data_clear $D"/live/SYSTEMD/test.txt"

