#!/bin/bash
# Script sshmem.sh use ssh-agent and ssh-add to remember your password when using git push or git pull and similar ssh things.
#--
# by B.K. aka t3ch - w4d4f4k at gmail dot com
#--
# MOTO: If is possible make it simpler... ;)
#--
#
source $(pwd)/sshmem.sh
#
eval $(ssh-agent -s)
sleep 1
ssh-add
