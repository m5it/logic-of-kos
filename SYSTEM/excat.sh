#!/bin/bash
#
# excat - a tool used to exclude same lines and concat two files
#--
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/../"
source $PRE'prepare.sh' # include prepared global variables like: realpath, filenick, filename..

#--
# Define variables for pca.sh ( parse command line arguments )
#--
# Display help if no args set...
PCA_ON_NONE_HELP=true
# Define array of available argument options
# - (VOCABNAME)
PCA=("VOCAB FROM1 FROM2 TO")
# Define variables where options are parsed as values
ARG_VOCAB=()
ARG_FROM1=()
ARG_FROM2=()
ARG_TO=()
#-- forma - options
# Options for arg CREATE
VOCAB_SHORT_ARG="-V"        #
VOCAB_ARG="--vocab"        #
VOCAB_VAL=true              # true | false ( if argument contain value )
#
FROM1_SHORT_ARG="-f1"
FROM1_ARG="--file1"
FROM1_VAL=true               # true | false ( if argument contain value )
#FROM1_VNM=2                   # how many values have this arg (default 1)
#
FROM2_SHORT_ARG="-f2"
FROM2_ARG="--file2"
FROM2_VAL=true               # true | false ( if argument contain value )
#FROM2_VNM=2                   # how many values have this arg (default 1)
#
TO_SHORT_ARG="-t"
TO_ARG="--to"
TO_VAL=true

#--
# Parse command line arguments
source $PRE'pca.sh'

#--
#

if [[ ${ARG_VOCAB[0]} != "" ]]; then
	f1=${ARG_VOCAB[0]}"_perc.txk"
	f2=${ARG_VOCAB[0]}"_rand.txk"
	to=${ARG_VOCAB[0]}"_data.txk"
	echo "f1: "$f1
	echo "f2: "$f2
	echo "to: "$to
	source $PRE'continue.sh'
	grep -Fxv -f $f1 $f2 > tmp.excat
	cat $f1 tmp.excat > $to
	rm tmp.excat
	exit
else
	if [[ ${ARG_FROM1[0]} != "" && ${ARG_FROM2[0]} != "" && ${ARG_TO[0]} != "" ]]; then
		f1=${ARG_FROM1[0]}
		f2=${ARG_FROM2[0]}
		to=${ARG_TO[0]}
		echo "f1: "$f1
		echo "f2: "$f2
		echo "to: "$to
		source $PRE'continue.sh'
		grep -Fxv -f $f1 $f2 > tmp.excat
		cat $f1 tmp.excat > $to
		rm tmp.excat
		exit
	fi
fi
echo "Check help, ex.: "$0" -h"
