#!/bin/bash
# `test.sh`
#
# Because we LOVE bash...! ;) ***
#
# Test include
echo "Including prepare.sh: "
PRE="" #
source prepare.sh

echo "Preview of prepare.sh variables (V, U, H, P): "
echo "V: "$V
echo "U: "$U
echo "H: "$H
echo "P: "$P

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
while true; do
	echo "loop..."
	sleep 1
done
