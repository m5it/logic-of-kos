#!/bin/bash
# Create virtual environment for python







#
if [[ $1 == "" ]]; then
	echo "Usage $0 nameOfVEnv"
	exit
fi
#
python3 -m venv $1
#
echo "To activate: "
echo "source "$1"/bin/activate"
echo "To deactivate: "
echo "deactivate"
