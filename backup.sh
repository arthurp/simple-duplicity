#!/bin/bash

set -euo pipefail

# Define some constants and variables
CONFIG_DIR=$HOME/.config/simple-duplicity
CONFIG_FILE=$CONFIG_DIR/backup.conf
EXCLUSION_FILE=$CONFIG_DIR/exclusions.conf

# Function to print usage message
usage() {
  echo "Usage: $0 [command]"
  echo ""
  echo "Options:"
  echo "  full          Perform a full backup"
  echo "  incremental   Perform an incremental backup"
  echo "  status        Print backup status"
  echo "  du            List files that would be backed up."
  echo ""
  exit 1
}

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    usage
fi

# Defaults
FULL_IF_OLDER_THAN=""

# Load config variables into shell
source "$CONFIG_FILE"

# Main script body
if [ $# -eq 0 ]; then
  usage
fi

COMMAND=$1
shift

case $COMMAND in
    full)
        duplicity full "${OPTIONS[@]}" --exclude-filelist "$EXCLUSION_FILE" "$@" "$SOURCE" "$TARGET"
        ;;
    incremental)
        if [ -n "${FULL_IF_OLDER_THAN}" ]; then
            duplicity incremental "${OPTIONS[@]}" --full-if-older-than "${FULL_IF_OLDER_THAN}" --exclude-filelist "$EXCLUSION_FILE"  "$@" "$SOURCE" "$TARGET"
        else
            duplicity incremental "${OPTIONS[@]}" --exclude-filelist "$EXCLUSION_FILE"  "$@" "$SOURCE" "$TARGET"
        fi
        ;;
    status)
        duplicity collection-status "${OPTIONS[@]}" "$@" "$TARGET"
        ;;
    du)
        du --exclude-from="$EXCLUSION_FILE" --apparent-size -h "$@" "$SOURCE" | sort -h
        ;;
    *)
        usage
        ;;
esac