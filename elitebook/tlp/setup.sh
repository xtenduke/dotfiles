#!/bin/bash
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"

# power-profiles-daemon conflicts with TLP
if systemctl is-active --quiet power-profiles-daemon 2>/dev/null; then
    systemctl stop power-profiles-daemon
    systemctl mask power-profiles-daemon
    echo "Masked power-profiles-daemon"
fi

dnf install -y tlp tlp-rdw

install -m 644 "$DIR/tlp.conf" /etc/tlp.conf

systemctl enable --now tlp
tlp start
echo "TLP installed and started"
