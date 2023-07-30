#!/bin/bash
#--
# This is just a testing script.. it wont drop or what ever anything a tthe moment.
# We are trying to read args etc.. handle things good way.. :D***
# by t3ch
#
# Now i see we use Bash aka version 4.0 and above. Because of this we can handle special string modifications etc...*** love you all!
#--

#
FROM=$1
ACTION="SHOW"
if [[ $2 != "" ]]; then 
	ACTION=$2 
fi

#
if [[ "$FROM" == "" ]]; then
	echo "Ex. usage: "$0" 8.8.8.8"
	echo "           "$0" example.com"
	echo "           "$0" 8.8.8.8 [DROP/DEBUG]"
	exit
fi
echo "Using address: "$FROM" and ACTION: "$ACTION
# Check if ip if not lets retrive it
if [[ "$FROM" =~ ^([0-9].+[0-9].+[0-9].+[0-9])+$ ]]; then
	#
	justsothereisnoerror=""
else
	# Retrive ip from host
	FROM=$(host $FROM | awk '!/IPv6/ && /address/ {print $4}')
fi
#
whois $FROM > TMPWHOIS
NETRANGE=$(cat TMPWHOIS | grep NetRange | awk '{print $2"-"$4}')
INETNUM=$(cat TMPWHOIS | grep inetnum | awk '{print $2"-"$4}')
rm TMPWHOIS
#echo "netrange: "$NETRANGE
#echo "inetnum: "$INETNUM

#
if [[ "$ACTION" =~ SHOW|DROP|DEBUG ]]; then
	#
	if [[ "$INETNUM" != "" ]]; then
		echo "DROPPING inetnum on "$INETNUM
		tmp1=$(echo $INETNUM|awk '{print $1}')
		tmp2=$(echo $INETNUM|awk '{print $2}')
		if [[ "$ACTION" == "DEBUG" ]]; then
			echo "DEBUG tmp1: "$tmp1
			echo "DEBUG tmp1last: "${tmp1:0-1}
			echo "DEBUG tmp1less: "${tmp1:0:-1}
			echo "DEBUG tmp2: "$tmp2
		fi
		#
		if [[ "$tmp2" == "" ]]; then # Block ip only
			if [[ ${tmp1:0-1} == "-" ]]; then
				tmp1=${tmp1:0:-1}
			fi
			echo "Blocking ip only: "$tmp1
		else # Block range
			echo "Blocking range: "$tmp1"-"$tmp2
		fi
	#
	elif [[ "$NETRANGE" != "" ]]; then
		echo "DROPPING netrange on "$NETRANGE
		tmp1=$(echo $NETRANGE|awk '{print $1}')
		tmp2=$(echo $NETRANGE|awk '{print $2}')
		if [[ "$ACTION" == "DEBUG" ]]; then
			echo "DEBUG tmp1: "$tmp1
			echo "DEBUG tmp2: "$tmp2
		fi
		#
		if [[ "$tmp2" == "" ]]; then # Block ip only
			if [[ ${tmp1:0-1} == "-" ]]; then
				tmp1=${tmp1:0:-1}
			fi
			echo "Blocking ip only: "$tmp1
		else # Block range
			echo "Blocking range: "$tmp1"-"$tmp2
		fi
	#
	else
		echo "Failed, can not find ip or range!"
	fi
fi
