#!/bin/bash
#
PRE="../"               # perfix
source prepare.sh       # include prepared global variables like: realpath, filenick, filename..

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
	fi
done
