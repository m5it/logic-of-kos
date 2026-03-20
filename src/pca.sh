#!/bin/bash
#
# LOK Framework: prepare.sh, continue.sh, isadmin.sh, pca.sh
#
# Parse command args
#
# Optional variable:
# - PCA_ON_NONE_HELP=true|false    # display help info. if no arguments passed..
#
# Require global defined variables:
# - array PCA=("ARG1 ARG2 ARG3") ...
# - configuration variables:
#     ARG1_SHORT_ARG
#     ARG1_ARG
#     ARG1_VAL
#     ARG1_FUNCTION
#     Ex.:
#       ARG1_SHORT_ARG='-a1', ARG1_ARG='--arg1', ARG1_VAL=true|false, ARG1_FUNCTION={echo 'a';exit}...
#
# Required scripts:
# - prepare.sh
# - pca.sh
#
# Other global variables:
# - $P, $B, $V, $H, $U, $PRE, $APCA, $NPCA
# - APCA => define num of args
# - NPCA => 
#--
#
cnt_arg=0
next_arg=""
find_arg=false
debug=false
cnt_vnm=0
chk_vnm=0
#
if [[ $APCA == "" ]]; then
	APCA=$#
fi
#
if [[ $NPCA == "" ]]; then
	NPCA=0
fi
#
function HELP(){
	cat $PRE'src/hr.txk'
	echo $V
	cat $PRE'src/created.txk'
	cat $PRE'src/hr.txk'
	echo -ne "\nHelp for "$B"...:\n"
	if [[ -f $H ]]; then
		cat $H
	else
		echo -ne "Sorry can not find documentation for $B.\n"
	fi
}

#
if [[ "$#" -eq 0 && $PCA_ON_NONE_HELP == true ]]; then
	echo "d1"
	HELP
	exit 1
fi

#
for arg in "$@"; do
	if [[ $arg == '-d' || $arg == '--debug' ]]; then
		debug=true
	fi
done

#
#cnt=0
for arg in "$@"; do
	#let cnt+=1
	if [[ $arg == "-h" || $arg == "--help" ]]; then
		#let cnt+=1
		#echo "tmpc val: "${!cnt}
		HELP
		exit 1
	elif [[ $arg == "-v" || $arg == "--version" ]]; then
		echo $V
		exit 1
	elif [[ $next_arg != "" ]]; then
		if [[ ${!next_arg} == "" ]]; then
			declare -gx "$next_arg"="("$arg")" # Set value from STRING name!
		else
			declare "$next_arg"="("${!next_arg}" "$arg")"
		fi
		#
		let cnt_vnm=cnt_vnm+1
		if [[ $cnt_vnm -lt $chk_vnm ]]; then
			continue
		else
			next_arg=""
			cnt_vnm=0
			chk_vnm=0
		fi
		find_arg=true
	fi
	#
	for opca in $PCA; do
		#
		tmp_short_arg=$opca'_SHORT_ARG'   # -sA | -s
		tmp_arg=$opca'_ARG'               # --some-arg
		tmp_val=$opca'_VAL'               # true | false
		tmp_fun=$opca'_FUNCTION'          # fireFunction
		tmp_vnm=$opca'_VNM'
		#
		if [[ $arg == ${!tmp_short_arg} || $arg == ${!tmp_arg} ]]; then
			#
			let NPCA=NPCA+1
			find_arg=true
			#
			if [[ ${!tmp_vnm} == '' ]]; then
				declare -gx $tmp_vnm=1
			fi
			chk_vnm=${!tmp_vnm}
			
			# Argument contain value
			if [[ ${!tmp_val} == true ]]; then
				if [[ $debug == true ]]; then echo "PCA => Setting next_arg for "$opca; fi
				next_arg="ARG_"$opca
				#
				if [[ $((cnt_arg + 1)) -eq ${#@} ]]; then
					declare -gx "$next_arg"=true
				fi
			# Argument is set
			else
				if [[ $debug == true ]]; then echo "PCA => Declaring variable for "$opca; fi
				declare -gx "ARG_"$opca=true # Set true if no value for argument
			fi
			
			# Argument fire function
			if [[ $(type -t $tmp_fun) == "function" ]]; then
				if [[ $debug == true ]]; then echo "PCA => Running function for "$opca; fi
				$tmp_fun
			fi
		fi
	done
	let cnt_arg=cnt_arg+1
done

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
echo "DEBUG APCA: "$APCA
echo "DEBUG NPCA: "$NPCA
echo "DEBUG CMD ARGS( "$#" ): "
echo "1: "$1 # dirName Ex.: NET | VENV | SYS...
echo "2: "$2 # scriptName Ex.: cputemp | calcnipp...
echo "3: "$3 # SET | HELP | RUN | VIEW...
echo "4: "$4 # key | key=val
echo "5: "$5 # val
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
		for tmp in $(ls -l $PRE""$chek | grep -E "^l.*"); do
			echo "tmp: "$tmp
			IFS=' ' read -ra elms <<< "$tmp"
			#for elm in "${elms[@]}"; do
			#	echo "elm: "$elm
			#done
			#echo "elms: "${#elms[@]}" - "${elms[8]}
			#in_array "cputemp" "${elms[@]}"
			
			if [[ "${elms[8]}" == $2 ]]; then
				RN=${elms[10]} # real name of script "script.sh" else "script"
				echo "Got command: "$2
				echo "Path: "$PRE
				echo "line: "$line" vs chek: "$chek
				SP=$PRE""$chek"/"$RN
				echo "SP: "$SP
				echo "RN: "$SP
				#$($SP -h)
				$SP -h
				exit
			fi
		done
		if [[ "$2" == "" ]]; then
			echo "No command "$c1
			exit 0
		fi
	fi
done

# No action was specified, displaying help if exists...
if [[ $PCA_ON_NONE_HELP == true && $find_arg == false ]]; then
	echo "d2"
	HELP
	exit 1
fi
