#!/bin/bash
#--
# Script to delete DROPped ips or ranges from iptables
# by t3ch
#--
FILE="dropped.txt"
while read -r src; do
    echo "Unblocking: $src"
    iptables -D INPUT $src -j DROP
done < $FILE
