#!/bin/bash
#
#
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/../"
#
source $PRE'src/prepare.sh' # include prepared global variables like: realpath, filenick, filename..
#--
# Define variables for pca.sh ( parse command line arguments )
#--
# Display help if no args set...
PCA_ON_NONE_HELP=true
PCA=("MACHINE_NAME" "YES")

ARG_MACHINE_NAME=""           # ip address
ARG_MACHINE_NAME_STRING=true
MACHINE_NAME_SHORT_ARG="-M"
MACHINE_NAME_ARG="--machine_name"
MACHINE_NAME_VAL=true

ARG_YES=""
ARG_YES_STRING=false
YES_SHORT_ARG="-Y"
YES_ARG="--yes"
YES_VAL=false

# Parse command line arguments
source $PRE'src/pca.sh'
#
MACHINE_NAME=$ARG_MACHINE_NAME

if [[ ! -n "$MACHINE_NAME" || "$MACHINE_NAME" == "" ]]; then
	echo "Missing argument MACHINE_NAME"
	exit 1
fi

if [[ "$ARG_YES" != "true" ]]; then
	echo "Continuing... Sleep 3s"
	sleep 3
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

if [[ "$ARG_YES" != "true" ]]; then
	echo $0" Starting on machine: "$MACHINE_NAME". Sleeping 3s..."
	sleep 3
fi

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
#	echo $nip > /home/t3ch/script/vms/$MACHINE_NAME
else
	echo "IP is set already: "$tmp
fi
