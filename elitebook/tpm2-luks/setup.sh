#!/bin/bash
# Enrolls a TPM2 key into LUKS so the disk unlocks automatically at boot.
# Your existing password remains as a fallback — it is NOT removed.
#
# PCRs 0+7: binds to firmware state + secure boot state.
# If you change BIOS settings significantly, you may need to re-enroll.
#
# To re-enroll after a PCR change:
#   sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p3
#   sudo bash setup.sh
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

LUKS_DEV="/dev/nvme0n1p3"

if ! command -v systemd-cryptenroll &>/dev/null; then
    echo "Error: systemd-cryptenroll not found (need systemd 248+)"
    exit 1
fi

if [[ ! -b "$LUKS_DEV" ]]; then
    echo "Error: $LUKS_DEV not found — update LUKS_DEV in this script"
    exit 1
fi

if ! ls /dev/tpm* &>/dev/null; then
    echo "Error: no TPM2 device found"
    exit 1
fi

echo "Enrolling TPM2 key into $LUKS_DEV (PCRs 0+7)..."
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 "$LUKS_DEV"

echo "Rebuilding initramfs..."
dracut -f

echo "Adding rd.luks.options=tpm2-device=auto to kernel cmdline..."
grubby --update-kernel=ALL --args="rd.luks.options=tpm2-device=auto"

echo ""
echo "Done. Reboot to test — the disk should unlock without a password prompt."
echo "Your existing LUKS password remains enrolled as a fallback."
echo ""
echo "To verify enrolled slots after reboot:"
echo "  sudo systemd-cryptenroll $LUKS_DEV"
