#!/bin/bash
#
CREATED="by Blaz Kos"
VERSION="Logic Of Kos - group.sh - v13.37"
#
#---


#
G=$1
#
if [[ $G == "" ]]; then
	cat /etc/group
else
	if [[ $G == "-h" || $G == "--help" ]]; then
		echo "Help for "$0
		echo "--------------------------------------------------------------"
		echo $CREATED
		echo "--------------------------------------------------------------"
		echo "-h        # Display all options for script"
		echo "-a        # Create new group"
		echo "-aG       # Add user to specific group"
		exit
	elif [[ $G == "-v" || $G == "--version" ]]; then
		echo $VERSION
		echo $CREATED
		exit
	elif [[ $G == "-a" ]]; then
		if [[ $2 == "" ]]; then
			echo "# Create new group"
			echo "Usage: $0 -a groupName"
			exit
		fi
		echo "Creating new group "$2
		groupadd $2
	elif [[ $G == "-aG" ]]; then
		if [[ $2 == "" || $3 == "" ]]; then
			echo "# Add user to specific group"
			echo "Usage: $0 -aG groupName userName"
			exit
		fi
		echo "Adding user "$3" to group "$2
		usermod -aG $2 $3
	else
		cat /etc/group | grep "$G"
	fi
fi
