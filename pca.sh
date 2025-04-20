#!/bin/bash
#
#
#
# Parse command args ( someFileName.pca )
#
#
#--
#
PRE="../"               # perfix
source prepare.sh       # include prepared global variables like: realpath, filenick, filename..
#
next_arg=""
#
for arg in "$@"; do
	if [[ $arg == "-h" || $arg == "--help" ]]; then
        	echo "Help for "$B"...:"
			cat $P'/'$PRE'hr.txk'
	        cat $P'/'$PRE'created.txk'
        	echo $V
	        cat $P'/'$PRE'hr.txk'
	        if [[ -f $H ]]; then
				cat $H
			else
				echo -ne "Sorry can not find documentation for $B.\n"
			fi
        	exit
	elif [[ $arg == "-v" || $arg == "--version" ]]; then
		echo $V
		exit
	elif [[ $next_arg != "" ]]; then
		declare -gx "$next_arg"=$arg # Set value from STRING name!
		next_arg=""
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
