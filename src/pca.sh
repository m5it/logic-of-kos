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
	#
	echo "Available options for "$B": "
	for opt in ${PCA[@]}; do
		#echo $opt
		if [[ "$B" == "lok" ]]; then
			echo $opt
		else
			SHORT=$opt"_SHORT_ARG"
			echo ${!SHORT}" # "$opt
		fi
	done
	#
	echo -ne "\nDocumentation for "$B": "
	#
	if [[ -f $H ]]; then
		cat $H
	else
		echo -ne "Can not find additional documentation for $B.\n"
	fi
}

#
if [[ "$#" -eq 0 && $PCA_ON_NONE_HELP == true ]]; then
	echo "d1"
	HELP
	exit 0
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
	# (integrated argument) help
	if [[ $arg == "-h" || $arg == "--help" ]]; then
		#let cnt+=1
		#echo "tmpc val: "${!cnt}
		HELP
		exit 1
	# (integrated argument) version
	elif [[ $arg == "-v" || $arg == "--version" ]]; then
		echo $V
		exit 1
	# (integrated argument) Run with configuration defined by lok
	elif [[ $arg == "-RR" || $arg == "--run_config" ]]; then
		echo "DEBUG -RR or --run_config START!"
		tmpd=$DL"/"$(basename $P)
		tmpf=$tmpd"/"$B"/config"
		echo "DEBUG config at tmpd: "$tmpf
		for tmp in $(cat $tmpf); do
			IFS=':' read -r -a arr <<< "$tmp"
			next_arg="ARG_"${arr[0]}
			echo "DEBUG config next_arg: "$next_arg" = "${arr[1]}
			declare -gx "$next_arg"="${arr[1]}"
			echo "DEBUG config tmp: "${!next_arg}
		done
	# (script arguments) Run with default script arguments
	elif [[ $next_arg != "" ]]; then
		ARG_OVERWRITE=$next_arg"_OVERWRITE"
		ARG_STRING=$next_arg"_STRING"
		if [[ ${!next_arg} == "" || ${!ARG_OVERWRITE} ]]; then
			# Here we will need to think which scripts require ARRAY or STRING and how to make an logic
			if [[ ${!ARG_STRING} ]]; then
				echo "d1, "$next_arg" = "$arg
				declare -gx "$next_arg"=""$arg"" # Set value from STRING name!
			else
				echo "d2"
				declare -gx "$next_arg"="("$arg")" # Set value from STRING name!
			fi
		else
			echo "DEBUG "$0" Dx1"
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

# No action was specified, displaying help if exists...
if [[ $PCA_ON_NONE_HELP == true && $find_arg == false ]]; then
	echo "d2"
	HELP
	exit 2
fi
