#!/bin/bash
# Quick git add/commit/push for current branch
# Supports .gitp/ in the working project directory:
#   .gitp/config               - key=value configuration
#   .gitp/hooks/BEFORE_ADD     - before 'git add .'
#   .gitp/hooks/BEFORE_COMMIT|AFTER_ADD  - before 'git commit'
#   .gitp/hooks/BEFORE_PUSH|AFTER_COMMIT - before 'git push'
#   Hook files ending in .sample are ignored (rename to activate).

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("REMOTE" "MESSAGE" "YES")

ARG_REMOTE=""
ARG_REMOTE_STRING=true
REMOTE_SHORT_ARG="-r"
REMOTE_ARG="--remote"
REMOTE_VAL=true

ARG_MESSAGE=""
ARG_MESSAGE_STRING=true
MESSAGE_SHORT_ARG="-m"
MESSAGE_ARG="--message"
MESSAGE_VAL=true

ARG_YES=""
ARG_YES_STRING=false
YES_SHORT_ARG="-Y"
YES_ARG="--yes"
YES_VAL=false

source $PRE'src/pca.sh'

REMOTE="${ARG_REMOTE:-origin}"
MESSAGE="${ARG_MESSAGE}"
YES="${ARG_YES:-false}"

GITP_DIR=".gitp"
GITP_HOOKS="$GITP_DIR/hooks"
GITP_CONFIG="$GITP_DIR/config"

DENY_AUTO_PUSH_BRANCH="master,main"

if [[ -f "$GITP_CONFIG" ]]; then
	while IFS='=' read -r key val; do
		[[ -z "$key" || "$key" == \#* ]] && continue
		key="${key// /}"
		val="${val//\"/}"
		case "$key" in
			DENY_AUTO_PUSH_BRANCH) DENY_AUTO_PUSH_BRANCH="$val" ;;
		esac
	done < "$GITP_CONFIG"
fi

run_hook() {
	local name="$1"
	local hook_path="$GITP_HOOKS/$name"
	if [[ -f "$hook_path" && -x "$hook_path" ]]; then
		echo "gitp: running $name hook..."
		if ! "$hook_path"; then
			echo "ERROR: $name hook failed. Aborting."
			exit 1
		fi
	elif [[ -f "$hook_path" ]]; then
		echo "gitp: warning: $name hook exists but is not executable. Skipping."
	fi
}

run_hook_aliases() {
	local a="$1"
	local b="$2"
	if [[ -f "$GITP_HOOKS/$a" || -f "$GITP_HOOKS/$b" ]]; then
		run_hook "$a"
		run_hook "$b"
	fi
	:
}

cbranch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [[ $? -ne 0 || -z "$cbranch" ]]; then
	echo "ERROR: Not in a git repository."
	echo "  Use -h for help"
	exit 1
fi

if [[ -z "$MESSAGE" ]]; then
	MESSAGE=$(git log -n1 --pretty="format:%s")
fi

if [[ "$YES" != "true" ]]; then
	echo "Branch: $cbranch"
	echo "Remote: $REMOTE"
	echo "Message: $MESSAGE"
	echo "Continue? (Y/n)"
	read TMP
	[[ "$TMP" != "Y" ]] && { echo "Exiting"; exit 1; }
fi

run_hook "BEFORE_ADD" || exit 1

git add . || exit 1

run_hook_aliases "BEFORE_COMMIT" "AFTER_ADD"

git commit -m "$MESSAGE" || exit 1

run_hook_aliases "BEFORE_PUSH" "AFTER_COMMIT"

# Prevent push only not add and commit
IFS=',' read -ra deny_branches <<< "$DENY_AUTO_PUSH_BRANCH"
for branch in "${deny_branches[@]}"; do
        branch="${branch// /}"
        if [[ "$cbranch" == "$branch" ]]; then
                echo "ERROR: Cannot push from '$branch' branch (denied by DENY_AUTO_PUSH_BRANCH)."
                echo "  Use -h for help"
                exit 1
        fi
done

git push "$REMOTE" || exit 1
