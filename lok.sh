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
#
PCA=("AVAILABLE PREVIEW UNINSTALL")
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
	for line in $(ls -d "$PRE"*[A-Z]*); do 
		if [[ -f $line ]]; then 
			continue; 
		fi;
		line=$(echo $line|awk '{print toupper($0)}')
		line=$(basename $line)
		chek=$(echo $1|awk '{print toupper($0)}')
		# Ex.: DEBUG line: VENV vs HELP
		#echo "DEBUG line: "$line" vs "$chek;
		if [[ $# == 0 ]]; then
			#echo "DEBUG lok.sh => $# is 0: "$line
			echo $line
		elif [[ "$chek" == "HELP" ]]; then
			echo "DEBUG lok.sh => Displaying help for lok!"
			HELP
			exit 1
		elif [[ "$chek" == "$line" ]]; then
			if [[ $# -eq 1 ]]; then
				echo "Available scripts: "
			fi
			#
			IFS=$'\n'
			for tmp in $(ls -l $PRE""$chek | grep -E "^l.*"); do
				# tmp: lrwxrwxrwx 1 t3ch t3ch    9 mar 20 19:27 CREATE_IMG -> vmcrei.sh
				if [[ -n "$DEBUG" ]]; then
					echo "DEBUG lok.sh => tmp: "$tmp
				fi
				IFS=' ' read -ra elms <<< "$tmp"
				if [[ $# -eq 1 ]]; then
					echo ${elms[8]}
					#in_array "cputemp" "${elms[@]}"
				elif [[ "${elms[8]}" == $2 ]]; then
					RN=${elms[10]}            # real name of script "script.sh" else "script"
					SP=$PRE""$chek"/"$RN
					SN=$(strip_file_type $RN)
					livedir="$DL/$1/$SN"       # /home/t3ch/.config/lok/live/SYSTEMD/mscnet
					livefile=$livedir"/config"  # /home/t3ch/.config/lok/live/SYSTEMD/mscnet/config
					savesdir="$DS/$1/$SN"
					historydir="$DH/$1/$SN"
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
					if [[ $APCA == 2 || $3 == "HELP" || $3 == "help" ]]; then
						# Fire Help
						$SP -h
						#
						echo -e "\nAvailable lok commands: "
						echo "HELP SET GET SAVE CLEAR RUN VIEW HISTORY USE"
					elif [[ "$3" == "SET" ]]; then
						#
						if [[ $APCA == 5 ]]; then
							# key=$4, val=$5
							data_set "$livefile" "$4" "$5"
						elif [[ $APCA == 4 ]]; then
							# split KEY=VAL
							IFS='=' read -ra arr <<< "$4"
							data_set "$livefile" "${arr[0]}" "${arr[1]}"
						else
							echo "Warning: Something went wrong!"
							exit 1
						fi
					elif [[ "$3" == "GET" ]]; then
						echo "Firing GET KEY"$4
					elif [[ "$3" == "DEL" ]]; then
						echo "Firing DEL KEY"$4
					elif [[ "$3" == "VIEW" ]]; then
						if [[ ! -f "$livefile" ]]; then
							echo $livefile" dont exists yet! Use SET to configure it."
							exit 1
						fi
						cat "$livefile"
					# clear life file / config
					elif [[ "$3" == "CLEAR" ]]; then
						echo "" > "$livefile"
						echo $livefile" is empty!"
					elif [[ "$3" == "HISTORY" ]]; then
						if [[ ! -f "$historydir/history.log" ]]; then
							echo "History yet dont exists."
							exit 1
						fi
						#
						cat $historydir"/history.log" | nl -v 1
					elif [[ "$3" == "USE_HISTORY" ]]; then
						if [[ ! -f "$historydir/history.log" ]]; then
							echo "History yet dont exists."
							exit 1
						fi
						#
						line=$(sed -n $4'p' $historydir'/history.log')
						if [[ $? -ne 0 ]]; then
							echo "Error occured at "$LINENO
							echo "Error: "$line
							exit 2
						fi
						echo "using line: "$line
						IFS=" | " read -ra arr <<< "$line"
						restore_lines "${arr[2]}" > "$livefile"
						exit 0
					elif [[ "$3" == "DISABLE_HISTORY" ]]; then
						echo "Firing DISABLE_HISTORY at "$4
					elif [[ "$3" == "RUN" ]]; then
						echo "Running: "$SP
						atmp=$($SP -RR)
						ERR=$?
						IFS=$'\n'
						if [[ $ERR -ne 0 ]]; then
							echo "ERROR "$U"( "$ERR" ) line "$LINENO". More: "
							print_array "${atmp[@]}"
							exit 1
						fi
						#
						for tmp in ${atmp[@]}; do
							echo $tmp
						done
						# Save history
						if [[ ! -f "$livefile" ]]; then
							exit 2
						fi
						tmp=$(concat_lines "$livefile")
						tmpdata=$(get_datetime)" | "$tmp
						echo "Adding to history at "$historydir"/history.log "$tmpdata
						echo $tmpdata >> $historydir"/history.log"
						
					else
						echo "Available lok commands: "
						echo "HELP SET GET DEL VIEW CLEAR RUN HISTORY USE_HISTORY DISABLE_HISTORY"
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
	find $PRE -maxdepth 2 ! -name "pca.sh" ! -name "isadmin.sh" ! -name "install.sh" ! -name 'continue.sh' ! -name 'prepare.sh' ! -path './tests*' ! -name 'test*' | grep -E "*.sh+$|*.py+$|*.php+$"
fi

