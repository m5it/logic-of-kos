#!/bin/bash
# From v0.1 available syntax:
#----------------------------
# Ex.:
# lok -l
# lok -u
# lok -p
# cputemp
# etc...
#
# From v0.3 available syntax:
#----------------------------
# Ex.: 
#   lok NET calcnipp HELP
#   lok NET calcnipp SET somekey=28
#   lok NET calcnipp SET somekey 28
#   lok NET calcnipp GET somekey
#   lok NET calcnipp VIEW
#   lok NET calcnipp RUN
# Welcome
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/"
source $PRE'src/prepare.sh' # include prepared global variables like: realpath, filenick, filename..
source $PRE'src/history.sh' # include history functionality
source $PRE'src/lok/commands.sh' # include modular commands
#
if [[ $# == 0 || $1 == "-h" ]]; then
	echo ""
	echo "You are using Logic Of Kos "$V" -> Collection of handy scripts for managing your XOS."
	echo ""
	cat $PRE'src/icon.txt'
	cat $PRE'src/hr.txk'
	echo $(cat $PRE'src/created.txk')
	echo ""
fi
#--
# Configure PCA
#
CNF_INSTALL=$PRE"install.dbk"
#echo "DEBUG lok.sh => PRE: "$PRE", CNF_INSTALL: "$CNF_INSTALL
#
#ARG_INSTALL=false
ARG_UNINSTALL=false
ARG_PREVIEW=false
ARG_AVAILABLE=false
ARG_HISTORY_ALL=false

ARG_REMOTE=""
ARG_REMOTE_NAME=""

REMOTE_SHORT_ARG="-r"
REMOTE_ARG="--remote"
REMOTE_VAL=false

REMOTE_NAME_SHORT_ARG="-R"
REMOTE_NAME_ARG="--remote-name"
REMOTE_NAME_VAL=false

PCA=("AVAILABLE" "PREVIEW" "UNINSTALL" "HISTORY_ALL" "REMOTE" "REMOTE_NAME")
#
PCA_ON_NONE_HELP=false
#
UNINSTALL_SHORT_ARG="-u"
UNINSTALL_ARG="--uninstall"
UNINSTALL_VAL=false
#
PREVIEW_SHORT_ARG="-p"
PREVIEW_ARG="--preview"
PREVIEW_VAL=false
#
AVAILABLE_SHORT_ARG="-a"
AVAILABLE_ARG="--available"
AVAILABLE_VAL=false

HISTORY_ALL_SHORT_ARG="-H"
HISTORY_ALL_ARG="--history-all"
HISTORY_ALL_VAL=false

# PARSE command line arguments
source $PRE"src/pca.sh"

#-- v0.3 UPDATE .. New Syntax Support.
#-------------------------------------
# Ex.: 
#   lok NET calcnipp HELP
#   lok NET calcnipp SET somekey=28
#   lok NET calcnipp SET somekey 28
#   lok NET calcnipp GET somekey
#   lok NET calcnipp VIEW
#   lok NET calcnipp RUN
# SEARCH FOR DIR COMMANDS
if [[ -n "$DEBUG" ]]; then
	echo "DEBUG lok.sh => PCA: "${PCA[@]}
	echo "DEBUG lok.sh => PCA.len: "${#PCA[@]}
	echo "DEBUG lok.sh => APCA: "$APCA
	echo "DEBUG lok.sh => NPCA: "$NPCA
	echo "DEBUG lok.sh => CMD ARGS( "$#" ): "
	echo "DEBUG lok.sh => 0: "$(basename $0) # dirName Ex.: NET | VENV | SYS...
	echo "DEBUG lok.sh => 1: "$1 # dirName Ex.: NET | VENV | SYS...
	echo "DEBUG lok.sh => 2: "$2 # scriptName Ex.: cputemp | calcnipp...
	echo "DEBUG lok.sh => 3: "$3 # SET | HELP | RUN | VIEW...
	echo "DEBUG lok.sh => 4: "$4 # key | key=val
	echo "DEBUG lok.sh => 5: "$5 # val
fi

if [[ $NPCA == 0 ]]; then
	#for line in $(find . -maxdepth 1 -type d -name '[A-Z]*'); do
	if [[ $# == 0 ]]; then
		echo "Available places: "
	fi
	HAVE_LINK=()
	IFS=$'\n'
	# Prepare available places, include links / exclude directories that contain link
	for line in $(ls -dl "$PRE"*[A-Z]*); do
		if [[ "$line" =~ ^l.* ]]; then
			HAVE_LINK+=($(echo $line|awk '{print toupper($11)}'))
		fi
	done
	#echo "HAVE_LINK: "$HAVE_LINK
	#in_array "SYSTEM" "${HAVE_LINK[@]}"
	#echo "HAVE_CHEK: "$?
	# Display available places
	for line in $(ls -dl "$PRE"*[A-Z]*); do 
		#echo "line: "$line
		full=$(echo $line|awk '{print $9}')
		priv=$(echo $line|awk -F ' ' '{print $1}')
		prog=$(basename $full|awk '{print toupper($0)}')
		chek=$(echo $1|awk '{print toupper($0)}')
		real=$chek
		#echo "DEBUG chek: "$chek
		#echo "DEBUG prog: "$prog
		#echo "DEBUG APCA: "$APCA
		#echo "DEBUG XX: "$#
		#
		if [[ $# -eq 0 && ( -f "$full" || $(in_array "$prog" "${HAVE_LINK[@]}") == "EXISTS" ) ]]; then
			continue; 
		fi;
		#
		if [[ "$priv" =~ ^l.* ]]; then
			real=$(echo $line|awk '{print $11}')
		fi
		#
		if [[ $# == 0 ]]; then
			echo -n "$prog"
			if [[ "$priv" =~ ^l.* ]]; then
				echo " => "$real
				chek=$real
			else
				echo ""
			fi
		elif [[ "$chek" == "HELP" ]]; then
			echo "DEBUG lok.sh => Displaying help for lok!"
			HELP
			exit 1
		elif [[ "$chek" == "$prog" ]]; then
			if [[ $# -eq 1 ]]; then
				echo "Available scripts: "
			fi
			#
			IFS=$'\n'
			for tmp in $(ls -l $PRE""$chek"/" | grep -E "^l.*"); do
			#for tmp in $(ls -l $PRE""$chek); do
				# tmp: lrwxrwxrwx 1 t3ch t3ch    9 mar 20 19:27 CREATE_IMG -> vmcrei.sh
				if [[ -n "$DEBUG" ]]; then
					echo "DEBUG lok.sh => tmp: "$tmp
				fi
				IFS=' ' read -ra elms <<< "$tmp"
				SCRIPT_NAME=$(basename "${elms[10]}" .sh)
				if [[ $# -eq 1 ]]; then
					echo ${elms[8]}
				elif [[ "${elms[8]}" == "${2^^}" || "${elms[8]}" == "$2" || "$SCRIPT_NAME" == "$2" ]]; then
					#
					RN=${elms[10]}            # real name of script "script.sh" else "script"
					SP=$PRE""$chek"/"$RN
					SN=$(strip_file_type $RN)
					#
					livedir="$DL/$chek/$SN"
					livefile=$livedir"/config"
					savesdir="$DS/$chek/$SN"
					historydir="$DH/$chek/$SN"
					# Check if $1 directory dont exists then create it
					if [[ ! -d "$livedir" ]]; then
						if ! mkdir -p "$livedir"; then
							echo "Failed creating "$livedir", check permissions!"
							exit 1
						fi
					fi
					#
					if [[ ! -d "$savesdir" ]]; then
						if ! mkdir -p "$savesdir"; then
							echo "Failed creating "$savesdir", check permissions!"
							exit 1
						fi
					fi
					#
					if [[ ! -d "$historydir" ]]; then
						if ! mkdir -p "$historydir"; then
							echo "Failed creating "$historydir", check permissions!"
							exit 1
						fi
					fi
					#
					if [[ -n "$DEBUG" ]]; then
						echo "DEBUG lok.sh => Got command: "$2
						echo "DEBUG lok.sh => Path: "$PRE
						echo "DEBUG lok.sh => line: "$line" vs chek: "$chek
						echo "DEBUG lok.sh => SP: "$SP
						echo "DEBUG lok.sh => RN: "$RN
						echo "DEBUG lok.sh => livedir: "$livedir
						echo "DEBUG lok.sh => livefile: "$livefile
						echo "DEBUG lok.sh => savesdir: "$savesdir
						echo "DEBUG lok.sh => historydir: "$historydir
					fi
					# Fire help
					if [[ $APCA == 2 || "${3^^}" == "HELP" ]]; then
						cmd_help
					elif [[ "${3^^}" == "SET" ]]; then
						cmd_set "$livefile" "${@:4}"
					elif [[ "${3^^}" == "GET" ]]; then
						cmd_get "$4"
					elif [[ "${3^^}" == "DEL" ]]; then
						cmd_del "$4"
					elif [[ "${3^^}" == "VIEW" ]]; then
						cmd_view "$livefile"
					elif [[ "${3^^}" == "CLEAR" ]]; then
						cmd_clear "$livefile"
					elif [[ "${3^^}" == "HISTORY" ]]; then
						cmd_history "$SN" "$4"
					elif [[ "${3^^}" == "USE_HISTORY" || "${3^^}" == "USE" ]]; then
						cmd_use "$SN" "$4" "$livefile"
					elif [[ "${3^^}" == "DISABLE_HISTORY" ]]; then
						cmd_disable_history "$4"
					elif [[ "${3^^}" == "RUN" ]]; then
						export LOK_DIR="$chek"
						cmd_run "$SP" "$livefile" "$SN" "$historydir" "$chek"
					else
						echo "Available lok commands: "
						echo "HELP SET GET DEL VIEW CLEAR RUN HISTORY USE"
					fi
				fi
			done
			#
			#if [[ "$2" == "" ]]; then
			#	echo "No command "$chek
			#	exit 0
			#fi
		fi
	done
fi
#echo "DEBUG args( "$?" ): "
##echo "ARG_INSTALL: "$ARG_INSTALL
#echo "ARG_UNINSTALL: "$ARG_UNINSTALL
#echo "ARG_PREVIEW: "$ARG_PREVIEW
#echo "ARG_AVAILABLE: "$ARG_AVAILABLE
#echo "ARG_HELP: "$ARG_HELP

#--
# MAIN
#--
if [[ $ARG_UNINSTALL == true ]]; then
	echo "LOK => Uninstalling..."
	source $PRE'continue.sh' # check if continue
	source $PRE'install.sh' -u
#
elif [[ $ARG_PREVIEW == true ]]; then
	echo "LOK => Preview..."
	#
	for data in $(cat $CNF_INSTALL); do
		fn=$(basename $data|sed 's/\.sh//g')
		echo $fn
	done
#
elif [[ $ARG_AVAILABLE == true ]]; then
	echo "LOK => Available..."
	#
	find $PRE -maxdepth 2 -type f \( -name "*.sh" -o -name "*.py" -o -name "*.php" \) ! -path "*/src/*" ! -path "*/tests/*" ! -name "lok.sh" ! -name "install.sh" ! -name "test*.sh" ! -name "*_test*"
#
elif [[ $ARG_HISTORY_ALL == true ]]; then
	echo "LOK => All History..."
	#
	for histdir in "$DH"/*; do
		[[ -d "$histdir" ]] || continue
		for subdir in "$histdir"/*; do
			if [[ -d "$subdir" && -f "$subdir/history.log" ]]; then
				script=$(basename "$subdir")
				dir=$(basename "$histdir")
				echo "=== $dir/$script ==="
				tac "$subdir/history.log" | head -5
				echo ""
			fi
		done
	done | head -50
fi


# Handle remote config management (-R flag)
if [[ -n "$ARG_REMOTE_NAME" ]]; then
	config_file="$HOME/.config/lok/remotes.conf"
	mkdir -p "$(dirname "$config_file")"
	
	# Parse: lok -R server_name [host:port] [token]
	if [[ $# -eq 0 ]]; then
		# List all remotes
		if [[ -f "$config_file" ]]; then
			echo "Configured remotes:"
			cat "$config_file" | nl
		else
			echo "No remotes configured."
			echo "Usage: lok -R <name> [host:port] [token]"
		fi
		exit 0
	elif [[ $# -eq 1 ]]; then
		# Show specific remote
		if [[ -f "$config_file" ]]; then
			entry=$(grep "^$1:" "$config_file")
			if [[ -n "$entry" ]]; then
				echo "Remote: $1"
				echo "$entry" | sed 's/:/ - /; s/:/ - Token: /'
			else
				echo "Remote '$1' not found."
			fi
		else
			echo "No remotes configured."
		fi
		exit 0
	else
		# Add/update remote
		host_port="$2"
		token="${3:-}"
		
		if [[ -z "$token" ]]; then
			# Try to get token from server
			echo "No token provided. Trying to get token from server..."
			token=$(curl -s "http://$host_port/ping" | grep -v "pong" | head -1)
			if [[ -z "$token" ]]; then
				echo "Warning: Could not get token automatically."
				echo "Please provide token: lok -R $1 $2 <token>"
			fi
		fi
		
		# Remove old entry and add new one
		if [[ -f "$config_file" ]]; then
			grep -v "^$1:" "$config_file" > "$config_file.tmp"
			mv "$config_file.tmp" "$config_file"
		fi
		echo "$1:$host_port:$token" >> "$config_file"
		echo "Added remote '$1' -> $host_port"
		exit 0
	fi
fi

# Handle remote execution (-r flag)
if [[ -n "$ARG_REMOTE" ]]; then
	# Parse host:port or name
	if [[ "$ARG_REMOTE" =~ ^[^:]+:[0-9]+$ ]]; then
		host="${ARG_REMOTE%:*}"
		port="${ARG_REMOTE##*:}"
		token_file="$HOME/.config/lok/remotes.conf"
		token=$(grep "^.*:$host:$port:" "$token_file" | head -1 | cut -d: -f3)
	else
		# Treat as name - look up in config
		token_file="$HOME/.config/lok/remotes.conf"
		entry=$(grep "^$ARG_REMOTE:" "$token_file" | head -1)
		if [[ -z "$entry" ]]; then
			echo "Error: Remote '$ARG_REMOTE' not found in $token_file"
			echo "Use: lok -R to configure remotes"
			exit 1
		fi
		host=$(echo "$entry" | cut -d: -f2)
		port=$(echo "$entry" | cut -d: -f3)
		token=$(echo "$entry" | cut -d: -f4)
	fi
	
	if [[ -z "$token" ]]; then
		echo "Error: No token found for $host:$port"
		exit 1
	fi
	
	# Build command string (skip -r and -R flags)
	args=()
	for ((i=1; i<=$#; i++)); do
		[[ "${!i}" == "-r" || "${!i}" == "--remote" || \
		 "${!i}" == "-R" || "${!i}" == "--remote-name" ]] && {
			((i++))
			continue
		}
		args+=("${!i}")
	done
	cmd_str="${args[*]}"
	
	# Send request
	response=$(curl -s -X POST "http://$host:$port/run" \
		-H "Authorization: Bearer $token" \
		-d "cmd=$cmd_str" 2>&1)
	
	echo "$response"
	exit 0
fi
