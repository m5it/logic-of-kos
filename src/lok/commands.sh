#!/bin/bash
# LoK Commands - Modular command functions

# HELP command
cmd_help() {
	$SP -h
	echo -e "\nAvailable lok commands: "
	echo "HELP SET GET DEL VIEW CLEAR RUN HISTORY USE"
}

# SET command - expects livefile and remaining args (key=val or key val)
cmd_set() {
	local livefile=$1
	shift
	local args=("$@")

	if [[ ${#args[@]} -eq 0 ]]; then
		echo "Warning: SET requires at least 1 argument (key=val or key val)"
		echo "Use '$0 -h' for help"
		exit 1
	fi

	for arg in "${args[@]}"; do
		if [[ "$arg" == *"="* ]]; then
			IFS='=' read -ra arr <<< "$arg"
			data_set "$livefile" "${arr[0]}" "${arr[1]}"
		else
			echo "Warning: Invalid argument '$arg'. Use key=value format"
			exit 1
		fi
	done
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

# RUN command - expects SP, livefile, SN, historydir, chek (directory name)
cmd_run() {
	local SP=$1
	local livefile=$2
	local SN=$3
	local historydir=$4
	local chekdir=$5
	local histpath="$historydir"
	if [[ -n "$chekdir" ]]; then
		histpath="$DH/$chekdir/$SN"
	fi
	atmp=$($SP -RR -Y)
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
	history_init_from_dir "$SN" "$histpath"
	history_add "$tmp"
}
