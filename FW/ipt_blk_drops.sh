#!/bin/bash
#--
# Script to DROP ips or ranges defined in $FILE=dropped.txt ...
# by t3ch
#--
FILE="dropped.txt"
while read -r src; do
    echo "Blocking: $src"
    iptables -A INPUT $src -j DROP
done < $FILE
