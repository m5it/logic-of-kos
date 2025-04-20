#!/bin/bash
#
#
#
#--
U=$(realpath $0)
#U=$(echo $U | sed "s/\//\x5C\//g")
B=$(basename $0 | sed 's/\.sh$//g')
#P=$(dirname $0 | sed 's/^\.\///g') # basename, realpath, dirname
P=$(dirname $U | sed 's/^\.\///g') # basename, realpath, dirname
V=$(cat $P'/'$PRE'version.txk' | sed "s/\[\-\-\#SCRIPT\_NAME\#\-\-\]/"$B"/g")
#H=$(echo $0 | sed 's/^\.\///g' | sed 's/\.sh$/\.sh\.txk/g' | (echo -n "help_for_" && cat))
H=$(echo -n $B | sed 's/\.sh$//g' | (echo -n "help_for_" && cat) | (echo -n $P"/" && cat) | sed 's/$/.txk/')
