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
