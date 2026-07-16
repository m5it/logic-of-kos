#!/bin/bash
# GMD GUI - Graphical user interface for GMD (LoK wrapper)
# Accessible as: lok GIT gmd-gui RUN or directly as gmd-gui

PRE=$(dirname $(realpath $0))"/../"
source $PRE'src/prepare.sh'
source $PRE'src/history.sh'
source $PRE'src/submodule.sh'

SM_PATH="$PRE/GIT/gmd"

PCA=()

PCA_ON_NONE_HELP=false

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

# Initialize history
SN="gmd-gui"
livedir="$DL/GIT/$SN"
livefile="$livedir/config"
if [[ ! -d "$livedir" ]]; then
	mkdir -p "$livedir"
fi

: > "$livefile"
history_init "$SN"
history_add "GUI launched"

# Execute the actual command
export PYTHONPATH="$SM_PATH:$PYTHONPATH"
python3 "$SM_PATH/scripts/gmd-gui" "$@"
