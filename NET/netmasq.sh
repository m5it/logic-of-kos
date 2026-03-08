#!/bin/bash
#
FROM=$1
TO=$2
ACTION=$3 # -A (default/add), -D (delete)
if [[ "$ACTION" == "" ]]; then
	ACTION="-A"
fi
#
if [[ "$FROM" == "" ]]; then
        echo "Usage: "$0" wlp9s0 br0"
        exit 1
fi
#
echo "Masquerading from: "$FROM", to: "$TO", action( -A | -D ): "$ACTION". Do you wish to continue? (Y/N)"
#
read CHK
if [[ "$CHK" != "Y" ]]; then
	echo "Bye."
	exit
fi
iptables -t nat $ACTION POSTROUTING -o $FROM -j MASQUERADE
iptables $ACTION FORWARD -i $FROM -o $TO -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables $ACTION FORWARD -i $TO -o $FROM -j ACCEPT
iptables $ACTION INPUT -i $TO -p udp -m udp --dport 67 -j ACCEPT
