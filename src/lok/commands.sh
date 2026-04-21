#!/bin/bash
# LoK Commands - Modular command functions

# HELP command
cmd_help() {
	$SP -h
	echo -e "\nAvailable lok commands: "
	echo "HELP SET GET DEL VIEW CLEAR RUN HISTORY USE"
}

# SET command - expects livefile, arg4, arg5, argcount
cmd_set() {
	local livefile=$1
	local arg4=$2
	local arg5=$3
	local argcount=$4

	if [[ $argcount == 2 ]]; then
		data_set "$livefile" "$arg4" "$arg5"
	elif [[ $argcount == 1 ]]; then
		IFS='=' read -ra arr <<< "$arg4"
		data_set "$livefile" "${arr[0]}" "${arr[1]}"
	else
		echo "Warning: SET requires 1 or 2 arguments (key=val or key val)"
		echo "Use '$0 -h' for help"
		exit 1
	fi
}

# GET command
cmd_get() {
	echo "Firing GET KEY"$2
}

# DEL command
cmd_del() {
	echo "Firing DEL KEY"$2
}

# VIEW command - expects livefile
cmd_view() {
	local livefile=$1
	if [[ ! -f "$livefile" ]]; then
		echo $livefile" dont exists yet! Use SET to configure it."
		exit 1
	fi
	cat "$livefile"
}

# CLEAR command - expects livefile
cmd_clear() {
	local livefile=$1
	echo "" > "$livefile"
	echo $livefile" is empty!"
}

# HISTORY command - expects SN, arg4
cmd_history() {
	local SN=$1
	local arg4=$2
	history_init "$SN"
	history_list "$arg4"
}

# USE command - expects SN, arg4, livefile
cmd_use() {
	local SN=$1
	local arg4=$2
	local livefile=$3
	history_init "$SN"
	line=$(history_get $arg4)
	if [[ $? -ne 0 ]]; then
		echo "Error occurred at $LINENO"
		echo "Error: $line"
		exit 2
	fi
	echo "using line: $line"
	data="${line#* | }"
	restore_lines "$data" > "$livefile"
	exit 0
}

# DISABLE_HISTORY command
cmd_disable_history() {
	echo "Firing DISABLE_HISTORY at "$2
}

# RUN command - expects SP, livefile, SN
cmd_run() {
	local SP=$1
	local livefile=$2
	local SN=$3
	atmp=$($SP -RR)
	ERR=$?
	IFS=$'\n'
	if [[ $ERR -ne 0 ]]; then
		echo "ERROR "$U"( "$ERR" ) line "$LINENO". More: "
		print_array "${atmp[@]}"
		exit 1
	fi

	for tmp in ${atmp[@]}; do
		echo $tmp
	done

	if [[ ! -f "$livefile" ]]; then
		exit 0
	fi

	tmp=$(concat_lines "$livefile")
	ERR=$?
	if [[ $ERR -ne 0 ]]; then
		echo "ERROR "$U"( "$ERR" ) line "$LINENO". More: "
		echo $tmp
		exit 1
	fi
	history_init "$SN"
	history_add "$tmp"
}
