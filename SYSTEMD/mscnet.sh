#!/bin/bash
# mscnet friend of vmcnet
# Set static ip and route for systemd-nspawned veth network
#--
# Ex.:
# 0.) Up with interface
# ip link set ve-gits.raw up
# 1.) First set master ip and broadcast!
# ip addr add 192.168.78.241/28 brd 192.168.78.255 dev ve-gits.raw
# 2.) Set master route
# ip route add 192.168.78.240/28 dev ve-gits.raw src 192.168.78.241
# 3.) Set IP of VM, in our example gits.raw is name of VM. We use lok->VENV->vmcnet.sh to set ip automatically depend how master is configured.
# vmcnet gits.raw
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
# Define array of available argument options
PCA=("IP PREFIX ROUTE BROADCAST INTERFACE ACTION")
# Define variables where options are parsed as values
ARG_IP=""           # ip address
ARG_IP_STRING=true
ARG_PREFIX=""       # ip prefix ex.: 28
ARG_PREFIX_STRING=true
ARG_ROUTE=""        # ip of route
ARG_ROUTE_STRING=true
ARG_BROADCAST=""    # broadcast ip
ARG_BROADCAST_STRING=true
ARG_INTERFACE=""    # eth0 or ve-yourveth.raw...
ARG_INTERFACE_STRING=true
ARG_ACTION="add"    # add | delete
ARG_ACTION_OVERWRITE=true
ARG_ACTION_STRING=true
#--
CAL_AVAILABLE_IPS=0 # calculate available ips with NET/calcnipp.sh [prefix]
#-- forma - options
# Options for args
#
IP_SHORT_ARG="-I"
IP_ARG="--ip"
IP_VAL=true               # true | false ( if argument contain value )
#
PREFIX_SHORT_ARG="-P"
PREFIX_ARG="--prefix"
PREFIX_VAL=true               # true | false ( if argument contain value )
#
ROUTE_SHORT_ARG="-R"
ROUTE_ARG="--route"
ROUTE_VAL=true               # true | false ( if argument contain value )
#
BROADCAST_SHORT_ARG="-B"
BROADCAST_ARG="--broadcast"
BROADCAST_VAL=true               # true | false ( if argument contain value )
#
INTERFACE_SHORT_ARG="-i"
INTERFACE_ARG="--interface"
INTERFACE_VAL=true               # true | false ( if argument contain value )
#
ACTION_SHORT_ARG="-a"
ACTION_ARG="--action"
ACTION_VAL=true               # true | false ( if argument contain value )

#--
# Parse command line arguments
source $PRE'src/pca.sh'
#
if [[ ! -n "$ARG_ACTION" || ! -n "$ARG_IP" || ! -n "$ARG_PREFIX" || ! -n "$ARG_ROUTE" || ! -n "$ARG_BROADCAST" || ! -n "$ARG_INTERFACE" ]]; then
	echo "Missing data!"
	exit 1
fi
# split ip into array
IFS=. read -r -a arr <<< "$ARG_IP"
#echo "arr: "${arr[3]}
##
#echo "PRE: "$PRE
#echo "ARG_ACTION: "$ARG_ACTION
#echo "ARG_IP: "$ARG_IP
#echo "ARG_PREFIX..: "$ARG_PREFIX
#echo "ARG_ROUTE: "$ARG_ROUTE
#echo "ARG_BROADCAST: "$ARG_BROADCAST
#echo "ARG_INTERFACE: "$ARG_INTERFACE
#CAL_AVAILABLE_IPS=`calcnipp $ARG_PREFIX`
#echo "CAL_AVAILABLE_IPS: "$CAL_AVAILABLE_IPS
#
INTERFACE_CMD="up" # up | down
if [[ "$ARG_ACTION" == "delete" ]]; then
	INTERFACE_CMD="down"
fi
# ip link set ve-gits.raw up
if ! ip link set $ARG_INTERFACE $INTERFACE_CMD; then
	echo "ERROR: Moving "$ARG_INTERFACE" "$INTERFACE_CMD"!"
	exit 1
fi
# ip addr add 192.168.78.241/28 brd 192.168.78.255 dev ve-gits.raw
if ! ip addr $ARG_ACTION $ARG_IP"/"$ARG_PREFIX brd $ARG_BROADCAST dev $ARG_INTERFACE; then
	echo "ERROR: Setting IP "$ARG_IP"/"$ARG_PREFIX" brd "$ARG_BROADCAST" dev "$ARG_INTERFACE
	exit 1
fi
# ip route add 192.168.78.240/28 dev ve-gits.raw src 192.168.78.241
if ! ip addr $ARG_ACTION $ARG_ROUTE"/"$ARG_PREFIX dev $ARG_INTERFACE src $ARG_IP; then
	echo "ERROR: Setting route "$ARG_ROUTE"/"$ARG_PREFIX" dev "$ARG_INTERFACE" src "$ARG_IP
	exit 1
fi
# Next run vmcnet to set hosts ip and route.
echo "All looks fine, now configure veth for VM. Use vmcnet [machineName]"
