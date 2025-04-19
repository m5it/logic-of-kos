#!/bin/bash
# Refs:
# - https://tldp.org/LDP/abs/html/restricted-sh.html
# Testing process substitution
# Testing functions
# Testing etc...


# Example 0
source test1.sh
source test2.sh
test2fun

echo "UID: "$UID
# Example 1
while read x1 x2 x3 x4 x5; do
#(
	echo "DEBUG( "$BASH_SUBSHELL" ): "$x1" - "$x2" - "$x3" - "$x4" - "$x5
#)
done < <(ls -l)

# Example 2
while read x; do ((y++)); done < <(ls -l)
echo $y

# Example 3
fun1() {
	echo "fun1("$BASH_SUBSHELL")"
}
fun1

function fun2() {
	echo "fun2()"
}
fun2
#SHELL="/bin/sh"
echo "a1: "$SHELL
set -r
function fun3 {
	echo "fun3()"
}
fun3
SHELL="/bin/sh"
echo "a2: "$SHELL

# Example 4
a=4
(
let a=a+1
echo "inside( "$BASH_SUBSHELL" ): "$a
)
echo "outside( "$BASH_SUBSHELL" ): "$a
