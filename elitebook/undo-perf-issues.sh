#!/bin/bash
# Undoes the power tweaks that cause performance/stutter issues:
#   - workload-hints service (blocks EPP, prevents CPU boosting)
#   - irq-affinity service (no-op for managed IRQs, pointless)
#   - pcie_aspm=force kernel param (causes PCIe/NVMe wake latency stutter)
#   - iwlwifi power_level=5 (too aggressive, causes network latency)
#
# Sleep config, GNOME settings, audio powersave, and other kernel params
# are intentionally left in place.
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

echo "=== Removing workload-hints ==="
systemctl disable --now workload-hints.service 2>/dev/null || true
rm -f /etc/systemd/system/workload-hints.service
echo 0 > /sys/devices/pci0000:00/0000:00:04.0/workload_hint/workload_hint_enable 2>/dev/null || true

echo ""
echo "=== Removing irq-affinity ==="
systemctl disable --now irq-affinity.service 2>/dev/null || true
rm -f /etc/systemd/system/irq-affinity.service
rm -f /usr/local/bin/irq-affinity.sh

systemctl daemon-reload

echo ""
echo "=== Removing pcie_aspm=force kernel param ==="
grubby --update-kernel=ALL --remove-args="pcie_aspm=force"

echo ""
echo "=== Removing iwlwifi power_level=5 ==="
echo "options iwlwifi power_save=1" > /etc/modprobe.d/iwlwifi-powersave.conf
dracut -f
echo "Rebuilt initramfs"

echo ""
echo "Done. Reboot for kernel param and modprobe changes to take effect."
