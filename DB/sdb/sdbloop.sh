#!/bin/bash
#--
# sdb.* v0.1 by B.K aka t3ch -> w4d4f4k at gmail dot com
# sdb.*          https://github.com/m5it
# sdb.* Script to sync local with remote database!
#**************** you are welcome **********************
#             ***    my friend    ***
#             ***********************
#--
# Used files:
# - sdb.config  ( configurations for remote and local db )
# - sdb.sh      ( main script that do the job )
# - sdbloop.sh  ( Define db names )
#--
source sdb.config
#
for DB in ${DBS[@]}; do
	DDB=${DB#*:}
	SDB=${DB%%:*}
	echo "SDB: $SDB"
	echo "DDB: $DDB"
	#
	./sdb.sh "$SDB" "$DDB"
done
echo "Done!"
