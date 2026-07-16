# AGENTS.md - Logic Of KOS (LoK)

A collection of bash scripts for system administration.

## Quick Commands

```bash
./lok.sh                    # Show available places (NET, SYSTEMD, SYSTEM, NGINX, etc.)
./lok.sh NET               # List scripts in NET directory
./lok.sh NET calcnipp HELP  # Get help for calcnipp script
./lok.sh NET calcnipp SET somekey=value  # Persist config for script
./lok.sh NET calcnipp RUN              # Run script with saved config
./lok.sh -a               # List all available scripts
./lok.sh -p               # Preview installed (linked) scripts
```

## Installation

```bash
./install.sh -l   # Link all .sh scripts to /usr/local/bin/
./install.sh -u   # Unlink installed scripts
./install.sh -L  # Change install location
```

## Structure

- `lok.sh` - Main entrypoint (also installed as `lok` command)
- `src/` - Framework library (prepare.sh, pca.sh, history.sh, etc.)
- `NET/`, `SYSTEMD/`, `SYSTEM/`, `NGINX/`, `DB/`, etc. - Category directories
- Help files: `help_for_SCRIPTNAME.txk` in root (e.g., `help_for_install.txk`)

## Framework Notes

- Scripts use `src/prepare.sh` for common variables and functions
- Config stored in `~/.config/lok/live/DIR/SCRIPT/config`
- History stored in `~/.config/lok/history/DIR/SCRIPT/`
- Subcommands: `HELP`, `SET`, `GET`, `DEL`, `VIEW`, `CLEAR`, `RUN`, `HISTORY`, `USE`

## PCA Variables (Required for all scripts)

Every script that integrates with the framework MUST define these before sourcing `pca.sh`:

```bash
PCA=("ARG1" "ARG2" ...)           # Array of argument names (uppercase)

PCA_ON_NONE_HELP=true|false      # Show help when no args passed

ARG_ARG1=""                       # Variable to hold the value
ARG_ARG1_STRING=true|false        # true=string, false=bool
ARG1_SHORT_ARG="-a"               # Short flag (e.g., -a)
ARG1_ARG="--arg1"                 # Long flag (e.g., --arg1)
ARG1_VAL=true|false               # true=takes value, false=boolean flag
```

**Variables set by prepare.sh:**
- `$PRE` - Path to lok root (with trailing /)
- `$B` - Script basename without .sh
- `$V` - Version string
- `$H` - Help file path
- `$U` - Full realpath of script
- `$D` - ~/.config/lok
- `$DL` - ~/.config/lok/live (config files)
- `$DS` - ~/.config/lok/saves
- `$DH` - ~/.config/lok/history

**Lok flags that conflict with script flags (must filter):**
- `-h`, `--help` - lok's help
- `-a`, `--available` - lok's list all
- `-r`, `--remote` - lok's remote execution
- `-RR`, `--run_config` - lok's run-with-config (loads config from $DL)
- `-Y`, `--yes` - lok's confirm flag

## Directory Convention

- Uppercase dirs: `NET/`, `SYSTEMD/`, `GIT/`, `DB/`, etc.
- Symlinks without .sh: friendly names pointing to scripts (e.g., `gmd-merge -> gmd-merge.sh`)
- `.sh` files: actual script implementations
- Submodules: in category dirs with `.lok.conf` metadata file