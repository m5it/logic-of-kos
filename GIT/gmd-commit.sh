#!/bin/bash
# GMD Commit - Git submodule batch commit tool (LoK wrapper)
# Accessible as: lok GIT gmd-commit RUN or directly as gmd-commit

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'
source $PRE'src/history.sh'
source $PRE'src/submodule.sh'

SM_PATH="$PRE/GIT/gmd"

PCA=("DIRECTORY" "MESSAGE" "CONFIG" "FORMAT" "DRY_RUN" "PUSH" "OPERATION" "SUBMODULES" "JOBS")

PCA_ON_NONE_HELP=true

ARG_DIRECTORY=""
ARG_DIRECTORY_STRING=true
DIRECTORY_SHORT_ARG="-M"
DIRECTORY_ARG="--directory"
DIRECTORY_VAL=true

ARG_MESSAGE=""
ARG_MESSAGE_STRING=true
MESSAGE_SHORT_ARG="-m"
MESSAGE_ARG="--message"
MESSAGE_VAL=true

ARG_CONFIG=""
ARG_CONFIG_STRING=true
CONFIG_SHORT_ARG="-c"
CONFIG_ARG="--config"
CONFIG_VAL=true

ARG_FORMAT=""
ARG_FORMAT_STRING=true
FORMAT_SHORT_ARG="-f"
FORMAT_ARG="--format"
FORMAT_VAL=true

ARG_DRY_RUN=false
DRY_RUN_SHORT_ARG="-n"
DRY_RUN_ARG="--dry-run"
DRY_RUN_VAL=false

ARG_PUSH=false
PUSH_SHORT_ARG=""
PUSH_ARG="--push"
PUSH_VAL=false

ARG_OPERATION=""
ARG_OPERATION_STRING=true
OPERATION_SHORT_ARG="-o"
OPERATION_ARG="--operation"
OPERATION_VAL=true

ARG_SUBMODULES=""
ARG_SUBMODULES_STRING=true
SUBMODULES_SHORT_ARG=""
SUBMODULES_ARG="--submodules"
SUBMODULES_VAL=true

ARG_JOBS=""
ARG_JOBS_STRING=true
JOBS_SHORT_ARG="-j"
JOBS_ARG="--jobs"
JOBS_VAL=true

# Special flags handled before PCA
for arg in "$@"; do
	if [[ "$arg" == "-HH" ]]; then
		# Show history of this tool
		SN="gmd-commit"
		history_init "$SN"
		history_list
		exit 0
	elif [[ "$arg" == "--tool-help" ]]; then
		# Show real submodule tool help
		if submodule_check "$SM_PATH"; then
			export PYTHONPATH="$SM_PATH:$PYTHONPATH"
			exec python3 "$SM_PATH/gmd/cli/commit.py" --help
		else
			echo "Error: Submodule 'gmd' is not installed." >&2
			exit 1
		fi
	fi
done

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
[[ -n "$ARG_DIRECTORY" ]] && ARGS+=("-M" "$ARG_DIRECTORY")
[[ -n "$ARG_MESSAGE" ]] && ARGS+=("-m" "$ARG_MESSAGE")
[[ -n "$ARG_CONFIG" ]] && ARGS+=("-c" "$ARG_CONFIG")
[[ -n "$ARG_FORMAT" ]] && ARGS+=("-f" "$ARG_FORMAT")
[[ "$ARG_DRY_RUN" == "true" ]] && ARGS+=("-n")
[[ "$ARG_PUSH" == "true" ]] && ARGS+=("--push")
[[ -n "$ARG_OPERATION" ]] && ARGS+=("-o" "$ARG_OPERATION")
[[ -n "$ARG_SUBMODULES" ]] && ARGS+=("--submodules" "$ARG_SUBMODULES")
[[ -n "$ARG_JOBS" ]] && ARGS+=("-j" "$ARG_JOBS")

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
SN="gmd-commit"
livedir="$DL/GIT/$SN"
livefile="$livedir/config"
if [[ ! -d "$livedir" ]]; then
	mkdir -p "$livedir"
fi

: > "$livefile"
[[ -n "$ARG_DIRECTORY" ]] && echo "DIRECTORY:$ARG_DIRECTORY" >> "$livefile"
[[ -n "$ARG_MESSAGE" ]] && echo "MESSAGE:$ARG_MESSAGE" >> "$livefile"
[[ -n "$ARG_CONFIG" ]] && echo "CONFIG:$ARG_CONFIG" >> "$livefile"
[[ -n "$ARG_FORMAT" ]] && echo "FORMAT:$ARG_FORMAT" >> "$livefile"
[[ "$ARG_DRY_RUN" == "true" ]] && echo "DRY_RUN:true" >> "$livefile"
[[ "$ARG_PUSH" == "true" ]] && echo "PUSH:true" >> "$livefile"
[[ -n "$ARG_OPERATION" ]] && echo "OPERATION:$ARG_OPERATION" >> "$livefile"
[[ -n "$ARG_SUBMODULES" ]] && echo "SUBMODULES:$ARG_SUBMODULES" >> "$livefile"
[[ -n "$ARG_JOBS" ]] && echo "JOBS:$ARG_JOBS" >> "$livefile"

history_init "$SN"
tmpdata=$(concat_lines "$livefile")
[[ -n "$tmpdata" ]] && history_add "$tmpdata"

# Execute the actual command
export PYTHONPATH="$SM_PATH:$PYTHONPATH"
python3 "$SM_PATH/gmd/cli/commit.py" "${ARGS[@]}"
exit $?

