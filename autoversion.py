#!/usr/bin/env python3
"""
Autoversion - Increment the third decimal of the framework version.

Usage:
    python3 autoversion.py

Reads version from `version.txk`, increments the last segment, and writes it back.
Examples:
    v0.3    -> v0.3.1
    v0.3.1  -> v0.3.2
    v1.2.9  -> v1.2.10
"""

import os
import re

VERSION_FILE = "version.txk"


def read_version(path):
    if not os.path.exists(path):
        return "0.0.0"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read().strip()
    # Strip leading 'v' prefix
    version = re.sub(r"^[vV]", "", content)
    return version


def write_version(path, version):
    with open(path, "w", encoding="utf-8") as f:
        f.write(f"v{version}\n")


def increment_version(version):
    parts = version.split(".")
    # Ensure we have at least 3 parts
    while len(parts) < 3:
        parts.append("0")
    # Increment last part
    try:
        last = int(parts[-1])
    except ValueError:
        last = 0
    parts[-1] = str(last + 1)
    return ".".join(parts)


def main():
    version = read_version(VERSION_FILE)
    new_version = increment_version(version)
    write_version(VERSION_FILE, new_version)
    print(f"Autoversion: {version} -> v{new_version}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
