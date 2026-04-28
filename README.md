#
# LOK -> Support two types of syntax.
#
# 1.) 
Default ex.: scriptname -A someaction -B anotherOption
#
# 2.) 
#
	LOK ex.: lok net scriptlink view
#
	LOK ex.: lok net scriptlink set IP=192.168.0.123
#
	LOK ex.: lok net scriptlink set PORT=1337
#
	LOK ex.: lok net scriptlink run
#
	LOK ex.: lok net scriptlink history
#
	LOK ex.: lok net scriptlink use 3
#
	LOK ex.: lok net scriptlink run

#
# Real example:
#
lok syd create_master_net set IP=192.168.79.241
#
lok syd create_master_net set RANGE=192.168.79.240
#
lok syd create_master_net set BROADCAST=192.168.79.255
#
lok syd create_master_net set PREFIX=28
#
lok syd create_master_net set INTERFACE=ve-somevm.raw
#
lok syd create_master_net run
