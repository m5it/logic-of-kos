#!/bin/bash
#--
# Script to generate ips and ip ranges that are DROPed with iptables
# by t3ch
#--
FILE="dropped.txt"
iptables -L -n | awk '!/range/ && /DROP/{print "-s "$4}' > $FILE
iptables -L -n | awk '/range/ && /DROP/{print "-m iprange --src-range "$9}' >> $FILE
n=$(cat $FILE | wc -l)
echo "Done. Num of results $n"
