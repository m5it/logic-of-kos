#!/bin/bash
#
# List virtual machines spawned with systemd-nspawn

command -v machinectl >/dev/null 2>&1 || { echo "machinectl not found. Install systemd-container package."; exit 1; }

machinectl list --no-legend
