#!/bin/bash
#
# LOK Framework: submodule.sh
# Reusable submodule detection, prompting, and installation functionality
#
# Usage:
#   source src/submodule.sh
#   submodule_check "./GIT/gmd"
#   submodule_prompt "gmd" "https://github.com/m5it/gmd.git"
#

# Submodule metadata (set by submodule_get_config)
SM_NAME=""
SM_URL=""
SM_SCRIPTS=""
SM_INSTALL=""
SM_TYPE=""

# submodule_check - Check if submodule directory exists and has content
# Usage: submodule_check "<submodule_path>"
# Returns 0 if installed, 1 if missing
submodule_check() {
	local path=$1
	if [[ -z "$path" ]]; then
		echo "Error: submodule_check() Missing argument 1 as submodule path" >&2
		return 1
	fi
	# Check if directory exists and is not empty
	if [[ -d "$path" ]] && [[ "$(ls -A "$path" 2>/dev/null)" ]]; then
		return 0
	fi
	return 1
}

# submodule_get_config - Read .lok.conf from submodule directory
# Usage: submodule_get_config "<submodule_path>"
# Sets: SM_URL, SM_SCRIPTS, SM_INSTALL, SM_NAME
submodule_get_config() {
	local path=$1
	local conf="$path/.lok.conf"
	# Reset
	SM_NAME=""
	SM_URL=""
	SM_SCRIPTS=""
	SM_INSTALL=""
	SM_TYPE=""
	if [[ ! -f "$conf" ]]; then
		echo "Warning: No .lok.conf found at $conf" >&2
		return 1
	fi
	while IFS=':' read -r key value; do
		[[ -z "$key" || "$key" == \#* ]] && continue
		key=$(echo "$key" | tr -d ' ')
		value=$(echo "$value" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
		case "$key" in
			NAME) SM_NAME="$value" ;;
			URL) SM_URL="$value" ;;
			SCRIPTS) SM_SCRIPTS="$value" ;;
			INSTALL) SM_INSTALL="$value" ;;
			TYPE) SM_TYPE="$value" ;;
		esac
	done < "$conf"
}

# submodule_install_git - Install submodule via git submodule update
# Usage: submodule_install_git "<submodule_path>"
submodule_install_git() {
	local path=$1
	local relpath
	# Make path relative to repo root
	if [[ "$path" == /* ]]; then
		relpath="$path"
	else
		relpath="$PRE$path"
	fi
	# Get the directory name relative to repo root
	local dir_name=$(echo "$relpath" | sed "s|^$PRE||" | sed 's|/$||')
	echo "Initializing submodule '$dir_name' via git..."
	if git submodule update --init "$dir_name"; then
		echo "Submodule '$dir_name' initialized successfully."
		return 0
	else
		echo "Error: Failed to initialize submodule '$dir_name'" >&2
		return 1
	fi
}

# submodule_install_clone - Install submodule via manual clone
# Usage: submodule_install_clone "<url>" "<target_path>"
submodule_install_clone() {
	local url=$1
	local target=$2
	echo "Cloning '$url' to '$target'..."
	if git clone "$url" "$target"; then
		echo "Clone successful."
		return 0
	else
		echo "Error: Failed to clone '$url'" >&2
		return 1
	fi
}

# submodule_prompt - Interactive prompt when submodule not found
# Usage: submodule_prompt "<name>" "<url>"
# Returns 0 if installed/ready, 1 if user skipped
submodule_prompt() {
	local name=$1
	local url=$2
	local sm_path="$PRE/GIT/$name"
	echo ""
	echo "Submodule '$name' is not installed."
	echo ""
	echo "Options:"
	echo "  1) Initialize via git submodule (recommended)"
	echo "  2) Clone manually from $url"
	echo "  3) Skip"
	echo ""
	read -p "Choose [1/2/3]: " choice
	case "$choice" in
		1)
			submodule_install_git "$sm_path"
			return $?
			;;
		2)
			submodule_install_clone "$url" "$sm_path"
			return $?
			;;
		3|*)
			echo "Skipped. Submodule '$name' is not available."
			return 1
			;;
	esac
}

# submodule_ensure - Check and prompt if needed, returns path to submodule
# Usage: submodule_ensure "<name>" "<path>"
# Returns 0 if submodule is ready, sets SM_PATH
submodule_ensure() {
	local name=$1
	local path=$2
	SM_PATH="$path"
	if submodule_check "$path"; then
		return 0
	fi
	# Load config if available
	submodule_get_config "$path" 2>/dev/null
	local url="${SM_URL:-}"
	if [[ -z "$url" ]]; then
		echo "Error: No URL found for submodule '$name'. Check .lok.conf" >&2
		return 1
	fi
	submodule_prompt "$name" "$url"
	return $?
}
