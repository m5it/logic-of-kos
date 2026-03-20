#!/bin/bash
# Calculate num of available ips in prefix
# Function to calculate usable IPs in a subnet
calculate_usable_ips() {
	local prefix=$1
 
	# Calculate 2^(32-prefix)
	local exponent=$((32 - prefix))
	local total_ips=$((2 ** exponent))
 
	# Calculate usable IPs (total_ips - 2)
	local usable_ips=$((total_ips - 2))
 
	#echo "For a /$prefix subnet:"
	#echo "Total IP addresses: $total_ips"
	#echo "Usable IP addresses: $usable_ips"
	echo $usable_ips
}
 
# Main script
if [ $# -eq 0 ]; then
	echo "Usage: $0 <CIDR prefix>"
	echo "Example: $0 28"
	exit 1
fi
 
prefix=$1
 
# Validate input
if ! [[ "$prefix" =~ ^[0-9]+$ ]] || [ "$prefix" -lt 0 ] || [ "$prefix" -gt 32 ]; then
	echo "Error: Prefix must be an integer between 0 and 32"
	exit 1
fi
 
calculate_usable_ips "$prefix"
