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
# - $P, $B, $V, $H, $U, $PRE
#--
#
next_arg=""
find_arg=false

#
function HELP(){
	cat $PRE'hr.txk'
	echo $V
	cat $PRE'created.txk'
	cat $PRE'hr.txk'
	echo -ne "\nHelp for "$B"...:\n"
	if [[ -f $H ]]; then
		cat $H
	else
		echo -ne "Sorry can not find documentation for $B.\n"
	fi
}

#
if [[ "$#" -eq 0 && $PCA_ON_NONE_HELP == true ]]; then
	HELP
	exit
fi

#
for arg in "$@"; do
	if [[ $arg == "-h" || $arg == "--help" ]]; then
			HELP
        	exit
	elif [[ $arg == "-v" || $arg == "--version" ]]; then
		echo $V
		exit
	elif [[ $next_arg != "" ]]; then
		declare -gx "$next_arg"=$arg # Set value from STRING name!
		next_arg=""
		find_arg=true
	fi
	#
	for opca in $PCA; do
		#
		tmp_short_arg=$opca'_SHORT_ARG'   # -sA | -s
		tmp_arg=$opca'_ARG'               # --some-arg
		tmp_val=$opca'_VAL'               # true | false
		tmp_fun=$opca'_FUNCTION'          # fireFunction
		#
		if [[ $arg == ${!tmp_short_arg} || $arg == ${!tmp_arg} ]]; then
			#
			find_arg=true
			# Argument contain value
			if [[ ${!tmp_val} == true ]]; then
				next_arg="ARG_"$opca
			# Argument fire function
			elif [[ $(type -t $tmp_fun) == "function" ]]; then
				$tmp_fun
			# Argument is set
			else
				declare -gx "ARG_"$opca=true # Set true if no value for argument
			fi
		fi
	done
done

# No action was specified, displaying help if exists...
if [[ $PCA_ON_NONE_HELP == true && $find_arg == false ]]; then
	HELP
	exit
fi
