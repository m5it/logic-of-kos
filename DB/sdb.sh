#!/bin/bash
#
# ---------------------------
# Script arguments
# ---------------------------

# ---------------------------
# Source Database Settings
# ---------------------------
SOURCE_USER="pub4all"
SOURCE_PASS="7gMeafZ"
SOURCE_HOST="lokkal.com"
SOURCE_PORT="3307"
SOURCE_DB="dlokkal.com_myvents"

# ---------------------------
# Destination Database Settings
# ---------------------------
DESTINATION_USER="pub4all"
DESTINATION_PASS="7gMeafZ"
DESTINATION_HOST="127.0.0.1"
DESTINATION_PORT="3306"
DESTINATION_DB="lokkal.com_myvents"
#
COUNT_SYNCED=0
COUNT_N=0
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
	#echo "Source Last ID: "$SOURCE_LAST_ID
	#echo "Destination Last ID: "$DESTINATION_LAST_ID
	if [[ "$SOURCE_LAST_ID" == "NULL" ]]; then
		echo "Continuing.. Null."
		continue
	fi
	if [[ $SOURCE_LAST_ID -eq $DESTINATION_LAST_ID ]]; then
		echo "Continuing.. Same ids."
		continue
	fi
	echo "Starting sync on table $T"
	echo "Source Last ID: "$SOURCE_LAST_ID
	echo "Destination Last ID: "$DESTINATION_LAST_ID
	echo "-----------------------------"
	# ---------------------------
	# Step 4: Sync data to destination using destination credentials
	#--
	#mariadb -u "$DESTINATION_USER" -p"$DESTINATION_PASS" -h "$DESTINATION_HOST" -P #"3306" -Nse "
	# INSERT INTO \`$DESTINATION_DB\`.\`$T\`
	# SELECT * FROM $SOURCE_HOST@$SOURCE_PORT.\`$SOURCE_DB\`.$T
	# WHERE $AC > $DESTINATION_LAST_ID
	#" --skip-ssl --verbose > sync.log 2>&1
	mariadb -u "$SOURCE_USER" -p"$SOURCE_PASS" "$SOURCE_DB" -h "$SOURCE_HOST" -P "$SOURCE_PORT" -Nse "mysqldump --no-create-info --where '$AC > $DESTINATION_LAST_ID' $SOURCE_DB.$T"
	#
	COUNT_SYNCED=$((COUNT_SYNCED+1))
done

echo "Ended..., synced "$COUNT_SYNCED


