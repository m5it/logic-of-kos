#!/bin/bash

#--
# WAN ROUTER - route settings
#Destination : 192.168.0.0/24
#Netmask     : 255.255.255.0
#Gateway     : 192.168.1.67   <-- (inner router’s LAN‑side IP)
#Interface   : LAN (br0/eth0)
#Metric      : 10

#--
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=0
sudo sysctl net.ipv6.conf.all.disable_ipv6=1
sudo sysctl net.ipv6.conf.default.disable_ipv6=1
sudo sysctl net.ipv6.conf.lo.disable_ipv6=1

#-- CLEAR IPTABLES
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X

#-- RUN IPBLOCK HERE
./block.sh

#-- LAN ROUTER - settings:
#sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o enp1s0 -j MASQUERADE
sudo iptables -A FORWARD -i enp2s0 -o enp1s0 -j ACCEPT
sudo iptables -A FORWARD -i enp1s0 -o enp2s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo ip addr add 192.168.0.1/24 brd + dev enp2s0
##sudo ip route add 192.168.1.1/32 via 192.168.1.67 dev enp1s0 table main
#sudo ip route add default via 192.168.1.67 dev enp1s0
#sudo ip route del default via 192.168.1.67 dev enp1s0
sudo ip route replace default via 192.168.1.1 dev enp1s0 metric 10

