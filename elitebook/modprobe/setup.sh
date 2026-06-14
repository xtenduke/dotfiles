#!/bin/bash
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"

install -m 644 "$DIR/audio-powersave.conf" /etc/modprobe.d/audio-powersave.conf
install -m 644 "$DIR/iwlwifi-powersave.conf" /etc/modprobe.d/iwlwifi-powersave.conf

dracut -f
echo "Installed modprobe configs and rebuilt initramfs"
echo "Reboot required for changes to take effect"
