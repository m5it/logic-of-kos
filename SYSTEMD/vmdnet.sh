#!/bin/bash
#
MACHINE_NAME=$1
#
CNT=0
IFS=$'\n'
for line in $(systemd-run -M $MACHINE_NAME --pipe ip addr show host0); do
	trim=$(echo $line | sed 's/^[[:space:]]*//')
	echo "trim: "$trim
	# inet 192.168.224.98/28 scope global host0
	if [[ "$trim" =~ ^inet[[:space:]]+([0-9]{1,3}\.){3}.+([16|24|28|32]).+scope.+global.+host0 ]]; then
                IFS=' ' read -r -a arr <<< "$trim"
		#echo "debug: "${arr[@]}
                if ! systemd-run -M $MACHINE_NAME --pipe ip addr delete ${arr[1]} dev ${arr[4]}; then
                        echo "ERROR deleting ip "${arr[1]}" dev "${arr[4]}
                        exit 1
                else
                        CNT=$((CNT += 1 ))
                fi
	fi
done
echo "Done. Removed ips: "$CNT
