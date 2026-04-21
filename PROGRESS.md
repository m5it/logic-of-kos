# LoK Progress Summary

## Date: 2026-04-21

---

## Recently Fixed/Updated

### lok.sh (Framework)
- Refactored commands to `src/lok/commands.sh` for modularity
- All commands now case-insensitive (lowercase/uppercase)
- SET now supports multiple key=value pairs: `lok br SET name=br0 route=192.168.3.1`

### netbr.sh
- Added ACTION option: -a ADD or -a DELETE
- Supports delete bridge functionality

### netfromto.sh
- Added ACTION option: -a ADD or -a DELETE
- Supports delete DNAT rule functionality

### vmlist.sh (SYSTEMD)

### vmlist.sh (SYSTEMD)
- Uses pca.sh framework with -h/-v built-in
- Added: `-s` / `--size` - show image size
- Added: `-l` / `--loop` - show loop device & location
- Added: `-a` / `--all` - show both size and loop info
- Added help file: help_for_vmlist.txk

### vmcrei.sh (SYSTEMD)
- Uses pca.sh framework
- Added disk space check before creating
- Added command verification (dd, gdisk, mkfs.ext4, qemu-img)
- Added image type: `-t raw` or `-t qcow2` (default: raw)
- Auto-detects type from filename extension (.qcow2, .raw, .img)
- Added: `-d` / `--debug` output
- Options: -n NAME -s SIZE -t TYPE

### cputemp.sh (SYSTEM)
- Uses pca.sh framework
- Added: `-d` / `--debug` - shows sensors as they're checked
- Added sudo warning for `-a` (--all) option
- Updated help file

### ipis.sh / ipfrom.sh (NET)
- Fixed caching - range-based keys now work
- Fixed prefix extraction bug in load_data_new
- Fixed "Checking cache" message filtering when called from other scripts
- Cache expires after 3 months (90 days)
- Added: `-d` / `--debug`
- Fixed save_data() using heredoc (was causing hangs)

### vmfnet.sh (SYSTEMD)
- Fixed `lok` path to use `/usr/local/bin/lok`
- Fixed subscripts paths: msdnet, vmdnet, vmcnet
- Added `-Y` option to skip confirmation
- Added `-Y` to all subscripts to skip 3-second sleeps
- Config now needs PREFIX=28 set (was missing)

### install.sh
- Added lok.sh linking to /usr/local/bin/lok
- lok.sh links without .sh extension

---

## Scripts Needing Testing

1. **vmcrei.sh** - needs sudo to install gdisk/e2fsprogs on other machines
2. **vmfnet.sh** - test with `-Y` flag: `sudo vmfnet -M base.raw -T 58 -Y`

---

## Notes

- When using lok framework with scripts, config must have all required variables
- Example: mscnet.sh requires IP, PREFIX, ROUTE, BROADCAST, INTERFACE
- Use `lok syd CREATE_MASTER_NET VIEW` to see current config
- Use `lok syd CREATE_MASTER_NET SET VAR=value` to set config

---

## Useful Commands

```bash
# Install/update
./install.sh -l         # Link all scripts
./install.sh -u         # Unlink

# Using lok framework
lok syd SCRIPT SET VAR=value
lok syd SCRIPT VIEW
lok syd SCRIPT RUN

# ipis/ipfrom
ipis -i 8.8.8.8        # Whois info
ipfrom -i 8.8.8.8      # Geo location
ipis -c                 # Clear cache
ipis -d -i 8.8.8.8     # Debug mode

# VMs
vmlist                  # List VMs
vmlist -a               # List with size+loop info
vmcrei.sh -n myvm.raw -s 10240

# Debug
SCRIPT -d -i value     # Debug output
```