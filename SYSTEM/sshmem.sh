#!/bin/bash
# Script sshmem.sh use ssh-agent and ssh-add to remember your password when using git push or git pull and similar ssh things.
#--
# by B.K. aka t3ch - w4d4f4k at gmail dot com
#--
# MOTO: If is possible make it simpler... ;)
#--
#!/bin/bash
#
#--
# Prepare global variables and data
PRE=$(dirname $(realpath $0))"/../"
#
source $PRE'src/prepare.sh' # include prepared global variables like: realpath, filenick, filename..
#--
# Define variables for pca.sh ( parse command line arguments )
#--
# Display help if no args set...
PCA_ON_NONE_HELP=false
# Define array of available argument options
PCA=()
#--
# Parse command line arguments
source $PRE'src/pca.sh'
#
#start_ssh_agent() {
#	eval $(ssh-agent -s)
#	export SSH_AUTH_SOCK
#	export SSH_AGENT_PID
#}
#start_ssh_agent
#systemctl --user start ssh-agent.service
#sleep 1
#ssh-add
echo "In progress..."
exit 2
