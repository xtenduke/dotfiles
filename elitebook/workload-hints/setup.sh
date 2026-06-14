#!/bin/bash
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"

# Verify the workload hint sysfs path exists on this machine
HINT_PATH="/sys/devices/pci0000:00/0000:00:04.0/workload_hint/workload_hint_enable"
if [[ ! -f "$HINT_PATH" ]]; then
    echo "Warning: $HINT_PATH not found — skipping (wrong machine or missing driver?)"
    exit 0
fi

install -m 644 "$DIR/workload-hints.service" /etc/systemd/system/

systemctl daemon-reload
systemctl enable --now workload-hints.service
echo "Installed workload-hints.service"
