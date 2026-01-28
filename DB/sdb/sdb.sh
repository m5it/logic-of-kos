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

#-- POSSIBLE ERRORS ON STEP 4:
# mariadb-dump: Error: 'Access denied; you need (at least one of) the PROCESS privilege(s) for this operation' when trying to dump tablespaces
# mariadb-dump: Got error: 1044: "Access denied for user 'pub4all'@'%' to database 'lokkal.com_myvents.photo_event'" when selecting the database

#-- THINK ON PRIVILEGES IF ALL IS SET CORRECTLY if not OBSERVE DEBUG outputs!
# GRANT PROCESS ON *.* TO 'youruser'@'%';
# FLUSH PRIVILEGES
# ---------------------------
#       --== START ==--
# ---------------------------
# Script arguments
# ---------------------------
USE_SOURCE_DB=$1
USE_DESTINATION_DB=$2
#
COUNT_SYNCED=0
COUNT_N=0
#
source sdb.config
#
if [[ "$SOURCE_DB" == "" ]]; then
	echo "exit"
	exit
fi
#--
# 
if [[ "USE_SOURCE_DB" != "" ]]; then
	SOURCE_DB=$USE_SOURCE_DB;
	if [[ $DEBUG == true ]]; then echo "Using SOURCE_DB: "$SOURCE_DB; fi
fi
if [[ "USE_DESTINATION_DB" != "" ]]; then
	DESTINATION_DB=$USE_DESTINATION_DB;
	if [[ $DEBUG == true ]]; then echo "Using DESTINATION_DB: "$DESTINATION_DB; fi
fi

# ---------------------------
# Get list of tables from source DB
TABLES=$(mariadb -h "$SOURCE_HOST" -u "$SOURCE_USER" -p"$SOURCE_PASS" -P$SOURCE_PORT -N -s -e "use $SOURCE_DB;show tables;" --skip-ssl)
for T in $TABLES; do
	if [[ $DEBUG==true ]]; then echo $COUNT_N".) Table: "$T; fi
	COUNT_N=$((COUNT_N+1))
	# ---------------------------
	# Step 1: Get auto-increment column name from source
	AC=$(mariadb -u "$SOURCE_USER" -p"$SOURCE_PASS" -h "$SOURCE_HOST" -P "$SOURCE_PORT" -Nse "
	  SELECT COLUMN_NAME 
	  FROM information_schema.COLUMNS 
	  WHERE TABLE_SCHEMA = '$SOURCE_DB' 
	    AND TABLE_NAME = '$T' 
	    AND EXTRA LIKE '%auto_increment%'
	" --skip-ssl)
	# ---------------------------
	# Step 2: Handle missing auto-increment column
	if [ -z "$AC" ]; then
	  echo "Warning: No auto-increment column found in table '$T'."
	  continue
	fi
	# ---------------------------
	# Step 3: Get last ID from source
	SOURCE_LAST_ID=$(mariadb -u "$SOURCE_USER" -p"$SOURCE_PASS" "$SOURCE_DB" -h "$SOURCE_HOST" -P "$SOURCE_PORT" -Nse "SELECT MAX($AC) FROM $T" --skip-ssl)
	DESTINATION_LAST_ID=$(mariadb -u "$DESTINATION_USER" -p"$DESTINATION_PASS" "$DESTINATION_DB" -h "$DESTINATION_HOST" -P "$DESTINATION_PORT" -Nse "SELECT MAX($AC) FROM $T" --skip-ssl)
	#
	if [[ "$SOURCE_LAST_ID" == "NULL" ]]; then
		if [[ $DEBUG == true ]]; then echo "Continuing.. Null."; fi
		continue
	fi
	if [[ $SOURCE_LAST_ID -eq $DESTINATION_LAST_ID ]]; then
		if [[ $DEBUG == true ]]; then echo "Continuing.. Same ids."; fi
		continue
	fi
	#
	if [[ $DEBUG == true ]]; then
		echo "-----------------------------"
		echo "Starting sync on table $T"
		echo "Auto increment id: "$AC
		echo "Source Last ID: "$SOURCE_LAST_ID
		echo "Destination Last ID: "$DESTINATION_LAST_ID
		echo "-----------------------------"
	fi
	# ---------------------------
	# Step 4: Sync data to destination using destination credentials
	#--
	mariadb-dump -h $SOURCE_HOST -P $SOURCE_PORT -u$SOURCE_USER -p$SOURCE_PASS $SOURCE_DB $T --no-create-info --skip-ssl --where "${AC} > ${DESTINATION_LAST_ID}" | mariadb -u$DESTINATION_USER -p$DESTINATION_PASS $DESTINATION_DB
	#
	COUNT_SYNCED=$((COUNT_SYNCED+1))
done

echo "Ended... It Is Synced. Your day is saved *** "$COUNT_SYNCED


