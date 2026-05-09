#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure some directories are created.
mkdir -p /config/chromium
mkdir -p /config/Downloads
mkdir -p /config/log/chromium

# Initialize log files.
for LOG_FILE in /config/log/chromium/output.log /config/log/chromium/error.log
do
    touch "$LOG_FILE"

    # Make sure the file doesn't grow indefinitely.
    if [ "$(stat -c %s "$LOG_FILE")" -gt 1048576 ]; then
        echo > "$LOG_FILE"
    fi
done

# vim:ft=sh:ts=4:sw=4:et:sts=4