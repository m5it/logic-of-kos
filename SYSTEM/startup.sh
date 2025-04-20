#!/bin/bash
# Add script / service to system startup.
#
service=$1
mng=$(ps --no-headers -o comm 1) # systemd | init
if [[ $mng == 'init' ]]; then
	echo "Using("$mng") openrc! Adding to startup "$service
	#
	#rc-service $service start
	rc-update add $service default # default or boot
else
	echo "Using("$mng") systemd! Adding to startup "$service
	systemctl start $service
fi
