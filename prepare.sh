#!/bin/bash
#
# LOK Framework: prepare.sh, continue.sh, isadmin.sh, pca.sh
#
#--
#echo "0: "$0
#echo "real 0: "$(realpath $0)
U=$(realpath $0)
#U=$(echo $U | sed "s/\//\x5C\//g")
#B=$(basename $0 | sed 's/\.sh$//g')
B=$(basename $(realpath $0) | sed 's/\.sh$//g')
P=$(dirname $U | sed 's/^\.\///g') # basename, realpath, dirname
#V=$(cat $P'/'$PRE'version.txk' | sed "s/\[\-\-\#SCRIPT\_NAME\#\-\-\]/"$B"/g")
V=$(cat $PRE'version.txk' | sed "s/\[\-\-\#SCRIPT\_NAME\#\-\-\]/"$B"/g")
H=$(echo -n $B | sed 's/\.sh$//g' | (echo -n "help_for_" && cat) | (echo -n $P"/" && cat) | sed 's/$/.txk/')
