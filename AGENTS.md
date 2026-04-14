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