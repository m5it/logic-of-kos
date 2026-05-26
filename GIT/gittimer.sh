#!/bin/bash
# gittimer - Timer daemon for auto-commit/auto-push

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'

TIMER_DIR="$D/GIT/gittimer"
PID_FILE="$TIMER_DIR/timer.pid"
LOG_FILE="$TIMER_DIR/timer.log"
SSH_ENV="$TIMER_DIR/ssh.env"

AC_DIR="$D/GIT/gitautocommit"
AC_FILE="$AC_DIR/instructions"
AP_DIR="$D/GIT/gitautopush"
AP_FILE="$AP_DIR/instructions"

ssh_status() {
	if [[ -z "$SSH_AUTH_SOCK" ]]; then
		echo "not available (no agent socket)"
		return 1
	fi
	if ! ssh-add -l &>/dev/null; then
		echo "no keys loaded"
		return 1
	fi
	local n=$(ssh-add -l 2>/dev/null | wc -l)
	echo "running ($n key(s))"
	return 0
}

setup_ssh() {
	if ssh_status &>/dev/null; then
		echo "SSH agent OK ($(ssh_status))"
		return 0
	fi

	echo "Starting ssh-agent..."
	eval $(ssh-agent -s)
	local rc=$?
	if [[ $rc -ne 0 ]]; then
		echo "ERROR: Failed to start ssh-agent"
		return 1
	fi

	echo "Running ssh-add (you may be prompted for a passphrase)..."
	ssh-add
	rc=$?
	if [[ $rc -ne 0 ]]; then
		echo "WARN: ssh-add returned $rc (no keys added?)"
	fi

	echo "$SSH_AUTH_SOCK" > "$SSH_ENV"
	echo "$SSH_AGENT_PID" >> "$SSH_ENV"
	return 0
}

load_ssh_env() {
	if [[ -f "$SSH_ENV" ]]; then
		local sock pid
		sock=$(head -1 "$SSH_ENV")
		pid=$(tail -1 "$SSH_ENV")
		if [[ -S "$sock" ]]; then
			export SSH_AUTH_SOCK="$sock"
			export SSH_AGENT_PID="$pid"
		fi
	fi
}

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
	else
		rm "$tmp"
	fi
}

update_timestamp() {
	local file="$1"
	local repo="$2"
	local now=$(get_timestamp_s)
	local tmp=$(mktemp)
	while IFS='|' read -r ts path remote branch; do
		[[ -z "$ts" ]] && continue
		if [[ "$path" == "$repo" ]]; then
			echo "$now|$path|$remote|$branch" >> "$tmp"
		else
			echo "$ts|$path|$remote|$branch" >> "$tmp"
		fi
	done < "$file"
	mv "$tmp" "$file"
}

process_file() {
	local file="$1"
	local mode="$2"
	local now=$(get_timestamp_s)

	if [[ ! -f "$file" ]]; then
		return
	fi

	while IFS='|' read -r ts path remote branch; do
		[[ -z "$ts" ]] && continue

		if [[ ! -d "$path" ]]; then
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] SKIP repo not found: $path" >> "$LOG_FILE"
			continue
		fi

		if [[ $((now - ts)) -le 300 ]]; then
			continue
		fi

		cd "$path" || continue
		if [[ -z $(git status --porcelain 2>/dev/null) ]]; then
			update_timestamp "$file" "$path"
			continue
		fi

		case "$mode" in
			commit)
				echo "[$(date '+%Y-%m-%d %H:%M:%S')] Auto-committing: $path" >> "$LOG_FILE"
				git add -A 2>/dev/null
				git commit -m "auto-commit: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE" 2>&1
				;;
			push)
				echo "[$(date '+%Y-%m-%d %H:%M:%S')] Auto-pushing: $path" >> "$LOG_FILE"
				remote_url=$(git remote get-url "$remote" 2>/dev/null)
				if [[ "$remote_url" == git@* || "$remote_url" == ssh://* ]]; then
					if ! ssh_status &>/dev/null; then
						echo "WARN: SSH agent $(ssh_status) for $remote_url" >> "$LOG_FILE"
					fi
				fi
				git add -A 2>/dev/null
				git commit -m "auto-push: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE" 2>&1
				if [[ -n "$branch" ]]; then
					git push "$remote" "$branch" >> "$LOG_FILE" 2>&1
				else
					git push "$remote" >> "$LOG_FILE" 2>&1
				fi
				;;
		esac

		update_timestamp "$file" "$path"
	done < "$file"
}

daemon_loop() {
	load_ssh_env
	migrate_file "$AC_FILE"
	migrate_file "$AP_FILE"
	while true; do
		process_file "$AC_FILE" "commit"
		process_file "$AP_FILE" "push"
		sleep 60
	done
}

if [[ "$1" == "--_daemon" ]]; then
	daemon_loop
	exit 0
fi

if [[ ! -d "$TIMER_DIR" ]]; then
	mkdir -p "$TIMER_DIR"
fi

PCA_ON_NONE_HELP=false
PCA=("START" "STOP" "STATUS")
ARG_START=false
ARG_STOP=false
ARG_STATUS=false
START_SHORT_ARG="-s"
START_ARG="--start"
START_VAL=false
STOP_SHORT_ARG="-d"
STOP_ARG="--stop"
STOP_VAL=false
STATUS_SHORT_ARG="-S"
STATUS_ARG="--status"
STATUS_VAL=false
source $PRE'src/pca.sh'

if [[ $ARG_START == true ]]; then
	if [[ -f "$PID_FILE" ]]; then
		pid=$(cat "$PID_FILE")
		if kill -0 "$pid" 2>/dev/null; then
			echo "gittimer already running (PID: $pid)"
			exit 0
		fi
		rm -f "$PID_FILE"
	fi

	setup_ssh

	"$0" --_daemon >> "$LOG_FILE" 2>&1 &
	disown
	echo $! > "$PID_FILE"
	echo "gittimer started (PID: $(cat $PID_FILE))"

elif [[ $ARG_STOP == true ]]; then
	if [[ ! -f "$PID_FILE" ]]; then
		echo "gittimer not running (no PID file)"
		exit 0
	fi
	pid=$(cat "$PID_FILE")
	if kill -0 "$pid" 2>/dev/null; then
		kill "$pid" 2>/dev/null
		echo "gittimer stopped (PID: $pid)"
	else
		echo "gittimer not running (stale PID)"
	fi
	rm -f "$PID_FILE"

elif [[ $ARG_STATUS == true ]]; then
	load_ssh_env

	if [[ -f "$PID_FILE" ]]; then
		pid=$(cat "$PID_FILE")
		if kill -0 "$pid" 2>/dev/null; then
			echo "gittimer RUNNING (PID: $pid)"
		else
			echo "gittimer STOPPED (stale PID file)"
		fi
	else
		echo "gittimer STOPPED"
	fi
	echo ""

	ac_count=0
	ap_count=0
	[[ -f "$AC_FILE" ]] && ac_count=$(wc -l < "$AC_FILE")
	[[ -f "$AP_FILE" ]] && ap_count=$(wc -l < "$AP_FILE")
	echo "Auto-commit repos: $ac_count"
	echo "Auto-push repos:   $ap_count"
	echo "SSH agent:         $(ssh_status)"

	echo ""
	[[ -f "$LOG_FILE" ]] && tail -5 "$LOG_FILE"

else
	echo "Usage: $0 -s (start) | -d (stop) | -S (status)"
	exit 1
fi
