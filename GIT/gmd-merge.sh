#!/bin/bash
# GMD Merge - Directory synchronization tool (LoK wrapper)
# Accessible as: lok GIT gmd-merge RUN or directly as gmd-merge

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'
source $PRE'src/history.sh'
source $PRE'src/submodule.sh'

SM_PATH="$PRE/GIT/gmd"

PCA=("MASTER" "SLAVE" "CONFIG" "ACTION" "FORMAT" "INTERACTIVE" "BACKUP" "DRY_RUN" "REVERSE" "EXCLUDES" "PROGRESS" "YES" "CATEGORIES")

PCA_ON_NONE_HELP=true

ARG_MASTER=""
ARG_MASTER_STRING=true
MASTER_SHORT_ARG="-M"
MASTER_ARG="--master"
MASTER_VAL=true

ARG_SLAVE=""
ARG_SLAVE_STRING=true
SLAVE_SHORT_ARG="-S"
SLAVE_ARG="--slave"
SLAVE_VAL=true

ARG_CONFIG=""
ARG_CONFIG_STRING=true
CONFIG_SHORT_ARG="-c"
CONFIG_ARG="--config"
CONFIG_VAL=true

ARG_ACTION=""
ARG_ACTION_STRING=true
ACTION_SHORT_ARG="-a"
ACTION_ARG="--action"
ACTION_VAL=true

ARG_FORMAT=""
ARG_FORMAT_STRING=true
FORMAT_SHORT_ARG="-f"
FORMAT_ARG="--format"
FORMAT_VAL=true

ARG_INTERACTIVE=false
INTERACTIVE_SHORT_ARG="-i"
INTERACTIVE_ARG="--interactive"
INTERACTIVE_VAL=false

ARG_BACKUP=false
BACKUP_SHORT_ARG="-b"
BACKUP_ARG="--backup"
BACKUP_VAL=false

ARG_DRY_RUN=false
DRY_RUN_SHORT_ARG="-n"
DRY_RUN_ARG="--dry-run"
DRY_RUN_VAL=false

ARG_REVERSE=false
REVERSE_SHORT_ARG="-r"
REVERSE_ARG="--reverse"
REVERSE_VAL=false

ARG_EXCLUDES=""
ARG_EXCLUDES_STRING=true
EXCLUDES_SHORT_ARG="-e"
EXCLUDES_ARG="--excludes"
EXCLUDES_VAL=true

ARG_PROGRESS=false
PROGRESS_SHORT_ARG="-p"
PROGRESS_ARG="--progress"
PROGRESS_VAL=false

ARG_YES=false
YES_SHORT_ARG="-y"
YES_ARG="--yes"
YES_VAL=false

ARG_CATEGORIES=""
ARG_CATEGORIES_STRING=true
CATEGORIES_SHORT_ARG=""
CATEGORIES_ARG="--categories"
CATEGORIES_VAL=true

source $PRE'src/pca.sh'

# Check if submodule is installed
if ! submodule_check "$SM_PATH"; then
	submodule_get_config "$SM_PATH" 2>/dev/null
	submodule_prompt "${SM_NAME:-gmd}" "${SM_URL:-https://github.com/m5it/gmd.git}" "$SM_PATH"
	[[ $? -ne 0 ]] && exit 1
	if ! submodule_check "$SM_PATH"; then
		echo "Error: Submodule still not available after install attempt." >&2
		exit 1
	fi
fi

# Build args from PCA variables
ARGS=()
[[ -n "$ARG_MASTER" ]] && ARGS+=("-M" "$ARG_MASTER")
[[ -n "$ARG_SLAVE" ]] && ARGS+=("-S" "$ARG_SLAVE")
[[ -n "$ARG_CONFIG" ]] && ARGS+=("-c" "$ARG_CONFIG")
[[ -n "$ARG_ACTION" ]] && ARGS+=("-a" "$ARG_ACTION")
[[ -n "$ARG_FORMAT" ]] && ARGS+=("-f" "$ARG_FORMAT")
[[ "$ARG_INTERACTIVE" == "true" ]] && ARGS+=("-i")
[[ "$ARG_BACKUP" == "true" ]] && ARGS+=("-b")
[[ "$ARG_DRY_RUN" == "true" ]] && ARGS+=("-n")
[[ "$ARG_REVERSE" == "true" ]] && ARGS+=("-r")
[[ -n "$ARG_EXCLUDES" ]] && ARGS+=("-e" "$ARG_EXCLUDES")
[[ "$ARG_PROGRESS" == "true" ]] && ARGS+=("-p")
[[ "$ARG_YES" == "true" ]] && ARGS+=("-y")
[[ -n "$ARG_CATEGORIES" ]] && ARGS+=("--categories" "$ARG_CATEGORIES")

# Also pass any raw arguments from command line (direct invocation, non-PCA flags)
if [[ ${#PCA[@]} -eq 0 ]]; then
	for arg in "$@"; do
		case "$arg" in
			-RR|-Y|--run_config) continue ;;
			*) ARGS+=("$arg") ;;
		esac
	done
fi

# Initialize history
SN="gmd-merge"
livedir="$DL/GIT/$SN"
livefile="$livedir/config"
if [[ ! -d "$livedir" ]]; then
	mkdir -p "$livedir"
fi

: > "$livefile"
[[ -n "$ARG_MASTER" ]] && echo "MASTER:$ARG_MASTER" >> "$livefile"
[[ -n "$ARG_SLAVE" ]] && echo "SLAVE:$ARG_SLAVE" >> "$livefile"
[[ -n "$ARG_ACTION" ]] && echo "ACTION:$ARG_ACTION" >> "$livefile"
[[ -n "$ARG_FORMAT" ]] && echo "FORMAT:$ARG_FORMAT" >> "$livefile"
[[ -n "$ARG_CONFIG" ]] && echo "CONFIG:$ARG_CONFIG" >> "$livefile"
[[ "$ARG_INTERACTIVE" == "true" ]] && echo "INTERACTIVE:true" >> "$livefile"
[[ "$ARG_BACKUP" == "true" ]] && echo "BACKUP:true" >> "$livefile"
[[ "$ARG_DRY_RUN" == "true" ]] && echo "DRY_RUN:true" >> "$livefile"
[[ "$ARG_REVERSE" == "true" ]] && echo "REVERSE:true" >> "$livefile"
[[ -n "$ARG_EXCLUDES" ]] && echo "EXCLUDES:$ARG_EXCLUDES" >> "$livefile"
[[ "$ARG_PROGRESS" == "true" ]] && echo "PROGRESS:true" >> "$livefile"
[[ "$ARG_YES" == "true" ]] && echo "YES:true" >> "$livefile"
[[ -n "$ARG_CATEGORIES" ]] && echo "CATEGORIES:$ARG_CATEGORIES" >> "$livefile"

history_init "$SN"
tmpdata=$(concat_lines "$livefile")
[[ -n "$tmpdata" ]] && history_add "$tmpdata"

# Execute the actual command
export PYTHONPATH="$SM_PATH:$PYTHONPATH"
python3 "$SM_PATH/gmd/cli/merge.py" "${ARGS[@]}"
exit_code=$?

echo ""
history_list 3

exit $exit_code
