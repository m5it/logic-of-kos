#!/bin/bash
#-------------------------
#-- gitp is:
#- quick push to dev. works only if not master.
#- ex. usage: ./gitp
#-            ./gitp remote_origin
#------------------------

#-- const vars
#GITDIR="/Users/t3ch/Projects/drdave/lokkal/alpha.lokkal.com/.git/"
#WORKTREE="/Users/t3ch/Projects/drdave/lokkal/alpha.lokkal.com/"
REMOTE=$1
#
if [[ "$REMOTE" == "" ]]; then
    REMOTE="origin"
fi

#--
cbranch=$(git rev-parse --abbrev-ref HEAD)
lastcommit=$(git log -n1 --pretty="format:%s")

#--
#if [ "$cbranch" == "master" ]; then
#    echo "gitp: You are in master branch. Quiting..."
#    exit 1
#fi

#--
echo "gitp: Current branch: "$cbranch", remote: "$REMOTE

#--
git add .
git commit -m "$lastcommit"

#--
if [ "$cbranch" == "master" ]; then
    echo "gitp: You are in master branch. Quiting..."
    exit 1
fi

git push $REMOTE
