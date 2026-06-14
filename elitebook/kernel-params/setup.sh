#!/bin/bash
# Adds power-saving kernel parameters via grubby (Fedora).
#
# Note: i915 PSR/FBC/DC params from the blog post are NOT included here —
# this machine uses the Intel Xe driver (xe.force_probe=7d45), not i915.
# PSR and power features are enabled by default in the Xe driver.
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

PARAMS=(
    "pcie_aspm=force"        # Force PCIe ASPM power saving on all devices
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
