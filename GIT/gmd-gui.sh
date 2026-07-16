#!/bin/bash
# GMD GUI - Graphical user interface for GMD (LoK wrapper)
# Accessible as: lok GIT gmd-gui RUN or directly as gmd-gui

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'
source $PRE'src/submodule.sh'

SM_PATH="$PRE/GIT/gmd"

# Check if submodule is installed
if ! submodule_check "$SM_PATH"; then
	submodule_get_config "$SM_PATH" 2>/dev/null
	submodule_prompt "${SM_NAME:-gmd}" "${SM_URL:-https://github.com/m5it/gmd.git}" "$SM_PATH"
	[[ $? -ne 0 ]] && exit 1
	# Verify it got installed
	if ! submodule_check "$SM_PATH"; then
		echo "Error: Submodule still not available after install attempt." >&2
		exit 1
	fi
fi

# Filter out LoK framework flags (-RR, -Y) not understood by Python tools
ARGS=()
for arg in "$@"; do
	case "$arg" in
		-RR|-Y|--run_config|--yes) continue ;;
		*) ARGS+=("$arg") ;;
	esac
done

# Execute the actual command
export PYTHONPATH="$SM_PATH:$PYTHONPATH"
exec python3 "$SM_PATH/scripts/gmd-gui" "${ARGS[@]}"
