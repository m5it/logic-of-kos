#!/bin/bash
#
ip link add br0 type bridge
ip addr add 192.168.3.1/24 brd + dev br0
ip link set br0 up
