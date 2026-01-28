#!/bin/bash
#-- POSSIBLE ERRORS ON STEP 4:
# mariadb-dump: Error: 'Access denied; you need (at least one of) the PROCESS privilege(s) for this operation' when trying to dump tablespaces
# mariadb-dump: Got error: 1044: "Access denied for user 'pub4all'@'%' to database 'lokkal.com_myvents.photo_event'" when selecting the database
#--
# GRANT PROCESS ON *.* TO 'youruser'@'%';
# FLUSH PRIVILEGES
# ---------------------------
# Script arguments
# ---------------------------
USE_SOURCE_DB=$1
USE_DESTINATION_DB=$2
# ---------------------------
# Source Database Settings
# ---------------------------
SOURCE_USER=""
SOURCE_PASS=""
SOURCE_HOST=""
SOURCE_PORT=""
SOURCE_DB=""
# ---------------------------
# Destination Database Settings
# ---------------------------
DESTINATION_USER=""
DESTINATION_PASS=""
DESTINATION_HOST=""
DESTINATION_PORT=""
DESTINATION_DB=""
a=[]
# Read config file
SOURCE_USER=$(cat sdb.config | awk -F'=' '/SOURCE_USER.*/{print $2}' | tr -d '"')
SOURCE_PASS=$(cat sdb.config | awk -F'=' '/SOURCE_PASS.*/{print $2}' | tr -d '"')
SOURCE_HOST=$(cat sdb.config | awk -F'=' '/SOURCE_HOST.*/{print $2}' | tr -d '"')
SOURCE_PORT=$(cat sdb.config | awk -F'=' '/SOURCE_PORT.*/{print $2}' | tr -d '"')
SOURCE_DB=$(cat sdb.config | awk -F'=' '/SOURCE_DB.*/{print $2}' | tr -d '"')
#
DESTINATION_USER=$(cat sdb.config | awk -F'=' '/DESTINATION_USER.*/{print $2}' | tr -d '"')
DESTINATION_PASS=$(cat sdb.config | awk -F'=' '/DESTINATION_PASS.*/{print $2}' | tr -d '"')
DESTINATION_HOST=$(cat sdb.config | awk -F'=' '/DESTINATION_HOST.*/{print $2}' | tr -d '"')
DESTINATION_PORT=$(cat sdb.config | awk -F'=' '/DESTINATION_PORT.*/{print $2}' | tr -d '"')
DESTINATION_DB=$(cat sdb.config | awk -F'=' '/DESTINATION_DB.*/{print $2}' | tr -d '"')
#
if [[ "$SOURCE_DB" == "" ]]; then
	echo "exit"
	exit
fi
#
COUNT_SYNCED=0
COUNT_N=0
#--
# 
if [[ "USE_SOURCE_DB" != "" ]]; then
	SOURCE_DB=$USE_SOURCE_DB;
	echo "Using SOURCE_DB: "$SOURCE_DB
fi
if [[ "USE_DESTINATION_DB" != "" ]]; then
	DESTINATION_DB=$USE_DESTINATION_DB;
	echo "Using DESTINATION_DB: "$DESTINATION_DB
fi

# ---------------------------
# Get list of tables from source DB
TABLES=$(mariadb -h "$SOURCE_HOST" -u "$SOURCE_USER" -p"$SOURCE_PASS" -P$SOURCE_PORT -N -s -e "use $SOURCE_DB;show tables;" --skip-ssl)
for T in $TABLES; do
	echo $COUNT_N".) Table: "$T
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

	echo "Auto-increment column: $AC"
	
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
		echo "Continuing.. Null."
		continue
	fi
	if [[ $SOURCE_LAST_ID -eq $DESTINATION_LAST_ID ]]; then
		echo "Continuing.. Same ids."
		continue
	fi
	echo "Starting sync on table $T"
	echo "Auto increment id: "$AC
	echo "Source Last ID: "$SOURCE_LAST_ID
	echo "Destination Last ID: "$DESTINATION_LAST_ID
	echo "-----------------------------"
	# ---------------------------
	# Step 4: Sync data to destination using destination credentials
	#--
	tt='$AC'
	echo "tt: "$tt
	#mariadb-dump -h $SOURCE_HOST -P $SOURCE_PORT -u$SOURCE_USER -p$SOURCE_PASS $SOURCE_DB $T #--no-create-info --skip-ssl --where '$AC > $DESTINATION_LAST_ID' | mariadb #-u$DESTINATION_USER -p$DESTINATION_PASS $DESTINATION_DB
	#
	COUNT_SYNCED=$((COUNT_SYNCED+1))
done

echo "Ended..., synced "$COUNT_SYNCED


