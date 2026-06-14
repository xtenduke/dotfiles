#!/bin/bash
# Master installer for EliteBook 840 G11 power tuning.
# Run each feature's setup independently, or use this to run all.
#
# Based on: https://blog.fsck.com/agent-blog/2026/03/30/linux-power-tuning-meteor-lake/
#
# Recommended order:
#   1. sleep/          — S0ix + suspend-then-hibernate (KEY)
#   2. tlp/            — CPU power management
#   3. modprobe/       — kernel module power settings
#   4. kernel-params/  — GRUB kernel cmdline
#   5. irq-affinity/   — pin IRQs to LP E-cores
#   6. workload-hints/ — Intel workload hint
#   7. gnome-power/    — GNOME settings (run as regular user)
#
# BEFORE running sleep/ setup:
#   sudo ./sleep/ltr-discover.sh
#   Edit sleep/ltr-ignore.sh and set LTR_IGNORE_INDICES to the
#   blocking indices shown by ltr-discover.sh.
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

_run_root() {
    local feature="$1"
    echo ""
    echo "=== $feature ==="
    bash "$DIR/$feature/setup.sh"
}

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

_run_root sleep
_run_root tlp
_run_root modprobe
_run_root kernel-params
_run_root irq-affinity
_run_root workload-hints

echo ""
echo "=== gnome-power ==="
echo "Run as your regular user:"
echo "  bash $DIR/gnome-power/setup.sh"

echo ""
echo "All done. Reboot for kernel param and modprobe changes to take effect."
