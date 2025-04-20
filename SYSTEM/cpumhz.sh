#!/bin/bash
echo "Using: "
cat /proc/cpuinfo | grep MHz
echo ""
echo "Additional info: "
lscpu | grep -i CPU
