#!/bin/bash
set -e
KVER="$(uname -r)"
INITRAMFS="/boot/initramfs-${KVER}.img"
BACKUP="${INITRAMFS}.acpi-rp11-pre"
[ -f "$BACKUP" ] && cp "$BACKUP" "$INITRAMFS" && rm "$BACKUP" && echo "Restored initramfs" || sudo dracut --force
rm -f "/usr/lib/kernel/install.d/90-acpi-rp11-d3cold.install" "/usr/lib/firmware/acpi/rp11-d3cold.aml"
echo "Done. Reboot."
