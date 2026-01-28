#!/bin/bash
# sdbloop.sh for sdb.sh
# Define multiple databases that should be synced.
#-------------------------------------------------
# By B.K. - t3ch - w4d4f4k at gmail dot com
#-------------------------------------------------
DBS=('dlokkal.com_myvents:lokkal.com_myvents' 'dlokkal.com_thevents:lokkal.com_thevents' 'zocalodigital2:lokkal.com')
for DB in ${DBS[@]}; do
	DDB=${DB#*:}
	SDB=${DB%%:*}
	echo "SDB: $SDB"
	echo "DDB: $DDB"
	#
	tmp=$(./sdb.sh "$SDB" "$DDB")
	#if [[ "$tmp" == "exit" ]]; then
	#	echo "Something is not right with sdb.config. Exiting."
	#	break
	#fi
done
echo "Done!"
