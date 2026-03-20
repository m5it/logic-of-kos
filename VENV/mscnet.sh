#!/bin/bash
# mscnet friend of vmcnet
# Set static ip and route for systemd-nspawned veth network
#--
# Ex.:
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
PCA=("IP PREFIX ROUTE")
# Define variables where options are parsed as values
ARG_IP=""           # ip address
ARG_PREFIX=""       # ip prefix ex.: 28
ARG_ROUTE=""        # ip of route
#--
CAL_AVAILABLE_IPS=0 # calculate available ips with NET/calcnipp.sh [prefix]
CAL_BRD=""          # calculate brd from available ips
#-- forma - options
# Options for args
#
IP_SHORT_ARG="-I"
IP_ARG="--ip"
IP_VAL=true               # true | false ( if argument contain value )
#
PREFIX_SHORT_ARG="-I"
PREFIX_ARG="--ip"
PREFIX_VAL=true               # true | false ( if argument contain value )
#
ROUTE_SHORT_ARG="-I"
ROUTE_ARG="--ip"
ROUTE_VAL=true               # true | false ( if argument contain value )

#--
# Parse command line arguments
source $PRE'src/pca.sh'

echo "PRE: "$PRE
echo "ARG_IP: "$ARG_IP
echo "ARG_PREFIX: "$ARG_PREFIX
echo "ARG_ROUTE: "$ARG_ROUTE
echo "CAL_AVAILABLE_IPS: "$CAL_AVAILABLE_IPS
echo "CAL_BRD          : "$CAL_BRD
