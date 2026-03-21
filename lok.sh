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
# From v0.2 available syntax:
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
VER="0.2"
PRE=$(dirname $(realpath $0))"/"
source $PRE'src/prepare.sh' # include prepared global variables like: realpath, filenick, filename..
#
if [[ $# == 0 || $1 == "-h" ]]; then
	echo ""
	echo "You are using Logic Of Kos v"$VER" -> Collection of handy scripts for managing your XOS."
	echo ""
	cat 'src/icon.txt'
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
#-- v0.2 UPDATE .. New Syntax Support.
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
	echo "DEBUG APCA: "$APCA
	echo "DEBUG NPCA: "$NPCA
	echo "DEBUG CMD ARGS( "$#" ): "
	echo "0: "$(basename $0) # dirName Ex.: NET | VENV | SYS...
	echo "1: "$1 # dirName Ex.: NET | VENV | SYS...
	echo "2: "$2 # scriptName Ex.: cputemp | calcnipp...
	echo "3: "$3 # SET | HELP | RUN | VIEW...
	echo "4: "$4 # key | key=val
	echo "5: "$5 # val
fi

if [[ $NPCA == 0 ]]; then
	#for line in $(find . -maxdepth 1 -type d -name '[A-Z]*'); do 
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
			echo "DEBUG $# is 0: "$line
		elif [[ "$chek" == "HELP" ]]; then
			echo "Displaying help for lok!"
			HELP
			exit 1
		elif [[ "$chek" == "$line" ]]; then
			#
			#ls -l $PRE""$chek | grep -E ".sh+$" | grep -v "^l"
			IFS=$'\n'
			#set -- ls -l "$PRE$chek" | grep -E "^l.*"
			for tmp in $(ls -l $PRE""$chek | grep -E "^l.*"); do
			#for tmp in "$@"; do
				# tmp: lrwxrwxrwx 1 t3ch t3ch    9 mar 20 19:27 CREATE_IMG -> vmcrei.sh
				if [[ -n "$DEBUG" ]]; then
					echo "tmp: "$tmp
				fi
				IFS=' ' read -ra elms <<< "$tmp"
				#for elm in "${elms[@]}"; do
				#	echo "elm: "$elm
				#done
				echo "elms: "${#elms[@]}" - "${elms[8]}
				#in_array "cputemp" "${elms[@]}"
				
				if [[ "${elms[8]}" == $2 ]]; then
					RN=${elms[10]}            # real name of script "script.sh" else "script"
					SP=$PRE""$chek"/"$RN
					if [[ -n "$DEBUG" ]]; then
						echo "Got command: "$2
						echo "Path: "$PRE
						echo "line: "$line" vs chek: "$chek
						echo "SP: "$SP
						echo "RN: "$RN
					fi
					# Fire help
					if [[ $APCA == 2 || $3 == "HELP" || $3 == "help" ]]; then
						$SP -h
					else
						echo "Unknown command! Available commands: "
						echo "HELP SET GET RUN VIEW CLEAR"
					fi
					exit
				fi
			done
			if [[ "$2" == "" ]]; then
				echo "No command "$c1
				exit 0
			fi
		fi
	done
fi
echo "DEBUG args( "$?" ): "
#echo "ARG_INSTALL: "$ARG_INSTALL
echo "ARG_UNINSTALL: "$ARG_UNINSTALL
echo "ARG_PREVIEW: "$ARG_PREVIEW
echo "ARG_AVAILABLE: "$ARG_AVAILABLE
echo "ARG_HELP: "$ARG_HELP

#--
# MAIN
#--
if [[ $ARG_UNINSTALL == true ]]; then
	echo "LOK => Uninstalling..."
	source $PRE'continue.sh' # check if continue
	source $PRE'install.sh' -u
elif [[ $ARG_PREVIEW == true ]]; then
	echo "LOK => Preview..."
	#
	for data in $(cat $CNF_INSTALL); do
		fn=$(basename $data|sed 's/\.sh//g')
		echo $fn
	done
elif [[ $ARG_AVAILABLE == true ]]; then
	echo "LOK => Available..."
	#
	find $PRE -maxdepth 2 ! -name "pca.sh" ! -name "isadmin.sh" ! -name "install.sh" ! -name 'continue.sh' ! -name 'prepare.sh' ! -path './tests*' ! -name 'test*' | grep -E "*.sh+$|*.py+$|*.php+$"
else
	echo "LOK => ELSE..."
fi

