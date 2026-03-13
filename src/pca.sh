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
# - $P, $B, $V, $H, $U, $PRE, $APCA
# - APCA define num of args
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
	#echo "d1"
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

echo "DEBUG ls PRE: "$PRE
# SEARCH FOR DIR COMMANDS
#for line in $(find . -maxdepth 1 -type d -name '[A-Z]*'); do 
for line in $(ls -d *[A-Z]*); do 
	if [[ -f $line ]]; then 
		continue; 
	fi;
	line=$(echo $line|awk '{print toupper($0)}')
	chek=$(echo $1|awk '{print toupper($0)}')
	#echo "line: "$line" vs "$chek;
	if [[ "$chek" == "$line" ]]; then
		#echo "got cmd1: "$line" 1: "$1
		c1=$(echo $1|awk '{print toupper($0)}')
		#
		ls -l $PRE""$c1 | grep -E ".sh+$" | grep -v "^l"
		#echo "DEBUG tmp: "$tmp
		if [[ "$2" == "" ]]; then
			#echo "No command "$c1
			exit
		fi
		#echo "got cmd2: "$line" 2: "$2
		#c2=$(echo $2|awk '{print toupper($0)}')
		tmp=$(ls -l $PRE""$c1 | grep -E ".*sh+$" | grep -E "^l.*" | awk '{print $9}' | grep $2)
		if [[ "$tmp" != "" ]]; then
			echo "CMD "$2
			exit
		else
			echo "tmp: "$tmp
		fi
	fi
done

# No action was specified, displaying help if exists...
if [[ $PCA_ON_NONE_HELP == true && $find_arg == false ]]; then
	#echo "d2"
	HELP
	exit 1
fi
