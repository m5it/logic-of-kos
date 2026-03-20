#!/bin/bash
# `test.sh`
#
# Because we LOVE bash...! ;) ***
#
# Test include
echo "Including prepare.sh: "
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/"
source $PRE'prepare.sh' # include prepared global variables like: realpath, filenick, filename..

echo "Preview of prepare.sh variables (V, U, H, B, P): "
echo "V: "$V
echo "U: "$U
echo "H: "$H
echo "P: "$P
echo "B: "$B

# Test objects
echo "Including testobj.h: "
source testobj.h
echo "Initializing testobj: "
testobj tobj
echo "Running function from testobj (tobj.sayHello): "
tobj.sayHello

# Test array
mya=("a1234 b1234 c1234")
echo "mya "$mya
echo "mya[0] "${mya[0]}
echo "mya[@] "${mya[@]}
echo "mya[@]:1:2 "${mya[@]:1:2}
echo "mya for "
for x in $mya; do
	echo "x: "${x:0:3}
done

# Test array function
function f1(){
	echo "this is f1()."
}
function f2(){
	echo "this is f2().."
}
#f1
myf=("f1 f2")
for x in $myf; do
	echo "x: "$x
	F=$x
	$F
done

# .. :)
t="/dev/sdb"
b=$(echo $t | grep -E "*.([0-9])+$")
echo "t: "$t
echo "b: "$b
cnt=0
while true; do
	echo "loop..."$cnt
	let cnt=cnt+1
	if [[ $cnt -ge 5 ]]; then
		exit
	fi
	sleep 3
done
