#
# LoK - Logic Of Kos v0.3
# Collection of handy bash scripts for system administration

## Quick Commands

```bash
./lok.sh                    # Show available places
./lok.sh NET               # List scripts in NET directory
./lok.sh NET calcnipp HELP  # Get help for calcnipp script
./lok.sh NET calcnipp SET key=value  # Persist config
./lok.sh NET calcnipp RUN              # Run script with saved config
./lok.sh -a               # List all available scripts
./lok.sh -p               # Preview installed (linked) scripts
./lok.sh -H               # Show all history
```

## Remote Execution (New!)

Run LoK commands on remote machines via HTTP API.

### Server Setup (on target machine):

```bash
# Start server
./src/lok-server.sh start

# Check status
./src/lok-server.sh status

# Stop server
./src/lok-server.sh stop

# Server generates token at ~/.config/lok/server_token
```

### Client Configuration:

```bash
# Add remote server
./lok.sh -R server1 192.168.1.10:19876 <token>

# List configured remotes
./lok.sh -R

# Show specific remote
./lok.sh -R server1
```

Config file: `~/.config/lok/remotes.conf`
Format: `name:host:port:token`

### Remote Execution:

```bash
# Execute on remote by IP:port
./lok.sh -r 192.168.1.10:19876 NET GEOIP RUN

# Execute on remote by name
./lok.sh -r server1 NET GEOIP RUN

# Set config on remote
./lok.sh -r server1 NET br SET name=br0
```

## Installation

```bash
./install.sh -l   # Link all .sh scripts to /usr/local/bin/
./install.sh -u   # Unlink installed scripts
./install.sh -L  # Change install location
```

## Framework Features

- **PCA (Parameter Command-line Arguments)** - Standardized argument parsing
- **Config persistence** - Save/load script configs in `~/.config/lok/live/`
- **History tracking** - All RUN commands logged in `~/.config/lok/history/`
- **Script symlinks** - Short names (NET/BR, NET/LN, etc.)
- **Case-insensitive** - Commands work with any case
- **Remote API** - HTTP server for remote execution
- **Modular commands** - HELP, SET, GET, DEL, VIEW, CLEAR, RUN, HISTORY, USE

## Structure

- `lok.sh` - Main entrypoint (also installed as `lok` command)
- `src/` - Framework library (prepare.sh, pca.sh, history.sh, commands.sh)
- `src/lok/` - Modular command functions
- `src/lok-server.sh` - HTTP API server for remote execution
- `NET/`, `SYSTEM/`, `SYSTEMD/`, etc. - Category directories
- Help files: `help_for_SCRIPTNAME.txk` in root or category dirs

## Recent Updates

### v0.3 (2026-04-22)
- Added remote execution via HTTP API (`-r`, `-R` flags)
- Modularized commands into `src/lok/commands.sh`
- Added case-insensitive command support
- Added `-H` flag to view all history
- NET/netln.sh - Supports bridge and veth interface types
- NET/netfromto.sh - Added ADD/DELETE actions
- SYSTEMD/vmcrei.sh - Support for raw/qcow2, auto-format (ext4 default)
- SYSTEMD/vmstart.sh, vmrcmd.sh - Framework integration
- History saved when running scripts directly (without lok)

## Examples

```bash
# Bridge management
lok NET LN SET name=br0 action=ADD
lok NET LN SET mac=00:11:22:33:44:55
lok NET LN RUN

# Network forwarding
lok NET FORWARD SET action=ADD from_port=8080 to_ip=192.168.1.10 to_port=80
lok NET FORWARD RUN

# VM management
lok SYSTEMD vmcrei -n test.raw -s 10240 -Y
lok SYSTEMD vmstart -i /home/chroots/test.raw -Y
lok SYSTEMD vmrcmd -M contabo-last 'ls -la /'

# Remote execution
lok -r server1 SYSTEM cputemp RUN
lok -r 192.168.1.10:19876 NET GEOIP "ip=8.8.8.8" RUN
```
