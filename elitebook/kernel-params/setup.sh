#!/bin/bash
# Adds power-saving kernel parameters via grubby (Fedora).
#
# Using i915 driver (not Xe). xe.force_probe and i915.force_probe=! are NOT set —
# the Xe driver caused kernel panics and hibernate failures on this hardware.
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

PARAMS=(
    "nmi_watchdog=0"         # Disable NMI watchdog (saves ~0.1W)
    "snd_hda_intel.power_save=1"  # Audio codec power saving
    "iwlwifi.power_save=1"   # Wi-Fi power saving
)

ARGS="${PARAMS[*]}"
echo "Adding kernel params: $ARGS"
grubby --update-kernel=ALL --args="$ARGS"

echo "Done. Reboot for changes to take effect."
echo ""
echo "Verify after reboot:"
echo "  cat /proc/cmdline"
