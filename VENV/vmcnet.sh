#!/bin/bash
#
#
MACHINE_NAME=""           # Machine name. Machine / VHost is created with systemd-nspawn
if [[ "$1" != ""  ]]; then
	MACHINE_NAME=$1
fi
HOST_IF="host0"                  # VHost interface
MAST_IF="ve-"$MACHINE_NAME       # Master interface
#
f=$(readlink -f $0)
n=$(basename $f)
p=$(dirname $f)
#echo "p: "$p
#echo "n: "$n
#echo "f: "$f

if [[ "$MACHINE_NAME" == "" ]]; then
	echo "Usage: "$0" machine.name"
	exit 1
fi
#
echo $0" Starting on machine: "$MACHINE_NAME". Sleeping 3s..."
sleep 3
#
source $p"/cmds.shi"
# Check if host0 is up
tmp=$(rcmd "ip addr list dev "$HOST_IF" | awk '/state UP/'")
if [[ "$tmp" == "" ]]; then
	echo "Moving link UP from DOWN...! :)"
	rcmd "ip link set "$HOST_IF" up"
else
	echo "Link already UP!"
fi

# Check if ip is set already
tmp=$(rcmd "ip addr list dev "$HOST_IF" | awk '/inet /{print \$2}'")
if [[ "$tmp" == "" ]]; then
	echo "IP not set!"
	tmp=$(ip addr list dev $MAST_IF | awk '/inet /{print $2}' | tail -n1)
	echo "Got route ip: "$tmp
	ip=$(echo $tmp| awk -F"/" '//{print $1}')
	pr=$(echo $tmp| awk -F"/" '//{print $2}')
	echo "IP: "$ip
	echo "PR: "$pr
	#
	IFS=. read -r -a arr <<< "$ip"
	echo "last: "${arr[3]}
	echo "next: "$((${arr[3]} + 1))
	#
	nip=${arr[0]}"."${arr[1]}"."${arr[2]}"."$((${arr[3]} + 1))
	echo "new ip: "$nip
	# ip addr add 192.168.36.50/28 dev host0
	# ip route add default via 192.168.36.49 dev host0 src 192.168.36.50
	# Set new IP
	rcmd "ip addr add "$nip"/"$pr" dev "$HOST_IF
	# Set route for IP
	rcmd "ip route add default via "$ip" dev "$HOST_IF" src "$nip
	#
	echo "Configuration done! New IP: "$nip
#	for elem in "${arr[@]}"; do
#		echo "Element: $elem"
#	done
	echo $nip > /home/t3ch/script/vms/$MACHINE_NAME
else
	echo "IP is set already: "$tmp
fi
