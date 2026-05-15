#!/bin/bash
# gitautocommit - Manage auto-commit directory list

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

PCA_ON_NONE_HELP=false
PCA=("ACTION" "LIST" "REMOTE" "BRANCH")

ARG_ACTION=""
ACTION_SHORT_ARG="-a"
ACTION_ARG="--action"
ACTION_VAL=true

ARG_LIST=false
LIST_SHORT_ARG="-l"
LIST_ARG="--list"
LIST_VAL=false

ARG_REMOTE=""
REMOTE_SHORT_ARG="-r"
REMOTE_ARG="--remote"
REMOTE_VAL=true

ARG_BRANCH=""
BRANCH_SHORT_ARG="-b"
BRANCH_ARG="--branch"
BRANCH_VAL=true

source $PRE'src/pca.sh'

ACTION="${ARG_ACTION:-add}"
REMOTE="${ARG_REMOTE:-origin}"
BRANCH="${ARG_BRANCH}"

REPO_PATH=""
SKIP=0
for arg in "$@"; do
	if [[ $SKIP -eq 1 ]]; then SKIP=0; continue; fi
	case "$arg" in
		-a|--action) SKIP=1 ;;
		-r|--remote) SKIP=1 ;;
		-b|--branch) SKIP=1 ;;
		-l|--list|-h|--help|-v|--version|-d|--debug|-RR|--run_config) ;;
		*) REPO_PATH="$arg" ;;
	esac
done

INSTRUCTIONS_DIR="$D/GIT/gitautocommit"
INSTRUCTIONS_FILE="$INSTRUCTIONS_DIR/instructions"

if [[ ! -d "$INSTRUCTIONS_DIR" ]]; then
	mkdir -p "$INSTRUCTIONS_DIR"
fi

migrate_file() {
	local file="$1"
	if [[ ! -f "$file" ]]; then return; fi
	local tmp=$(mktemp)
	local migrated=false
	while IFS= read -r line; do
		[[ -z "$line" ]] && continue
		if [[ "$line" != *"|"* ]]; then
			ts=$(echo "$line" | cut -d' ' -f1)
			path=$(echo "$line" | cut -d' ' -f2-)
			echo "$ts|$path|origin|" >> "$tmp"
			migrated=true
		else
			echo "$line" >> "$tmp"
		fi
	done < "$file"
	if [[ $migrated == true ]]; then
		mv "$tmp" "$file"
		echo "Migrated instructions file to new format"
	else
		rm "$tmp"
	fi
}
migrate_file "$INSTRUCTIONS_FILE"

if [[ $ARG_LIST == true ]]; then
	if [[ ! -f "$INSTRUCTIONS_FILE" ]]; then
		echo "No entries."
		exit 0
	fi
	printf "%-20s %-40s %-10s %s\n" "LAST_CHECK" "PATH" "REMOTE" "BRANCH"
	echo "--------------------------------------------------------------------------------"
	while IFS='|' read -r ts path remote branch; do
		[[ -z "$ts" ]] && continue
		if [[ "$ts" == "0" ]]; then
			check_str="never"
		else
			check_str=$(date -d "@$ts" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "$ts")
		fi
		printf "%-20s %-40s %-10s %s\n" "$check_str" "$path" "${remote:-origin}" "${branch:--}"
	done < "$INSTRUCTIONS_FILE"
	exit 0
fi

if [[ -z "$REPO_PATH" ]]; then
	echo "Usage: $0 [-a add|delete] [-r remote] [-b branch] /path/to/repo"
	echo "       $0 -l"
	exit 1
fi

REPO_PATH="${REPO_PATH%/}"

case "$ACTION" in
	add)
		if [[ ! -d "$REPO_PATH" ]]; then
			echo "Error: Directory '$REPO_PATH' does not exist"
			exit 1
		fi
		if [[ ! -d "$REPO_PATH/.git" ]]; then
			echo "Error: '$REPO_PATH' is not a git repository"
			exit 1
		fi
		while IFS='|' read -r ts path remote branch; do
			if [[ "$path" == "$REPO_PATH" ]]; then
				echo "Already in list: $REPO_PATH"
				exit 0
			fi
		done < "$INSTRUCTIONS_FILE" 2>/dev/null
		echo "$(get_timestamp_s)|$REPO_PATH|$REMOTE|$BRANCH" >> "$INSTRUCTIONS_FILE"
		echo "Added: $REPO_PATH (remote: $REMOTE${BRANCH:+, branch: $BRANCH})"
		;;
	delete)
		if [[ ! -f "$INSTRUCTIONS_FILE" ]]; then
			echo "No instructions file found"
			exit 1
		fi
		tmp=$(mktemp)
		found=false
		while IFS='|' read -r ts path remote branch; do
			[[ -z "$ts" ]] && continue
			if [[ "$path" == "$REPO_PATH" ]]; then
				found=true
			else
				echo "$ts|$path|$remote|$branch" >> "$tmp"
			fi
		done < "$INSTRUCTIONS_FILE"
		mv "$tmp" "$INSTRUCTIONS_FILE"
		if [[ $found == true ]]; then
			echo "Removed: $REPO_PATH"
		else
			echo "Not found in list: $REPO_PATH"
		fi
		;;
	*)
		echo "Error: Unknown action '$ACTION'. Use add or delete"
		exit 1
		;;
esac
