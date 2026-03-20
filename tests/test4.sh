#!/bin/bash
in_array() {
    local value=$1
    shift
    local array=("$@")
    i=0
    echo "in_array() START, array: ${array[@]}, value: $value"
 
    for val in "${array[@]}"; do
        echo "in_array val: $val"
        if [[ "$val" == "$value" ]]; then
            echo "Value '$value' found in array"
            return $i
        fi
	i=$((i+1))
    done
 
    echo "Value '$value' not found in array"
    return -1
}
# test array
mya=("a" "b" "c")
mya+=("d" "e")
echo "mya test: "$mya
echo "mya len: "${#mya[@]} # Size of array
echo "mya all: "${mya[@]}
echo "mya[1]: "${mya[1]}
#
in_array "d" "${mya[@]}"
echo "ret: "$?
