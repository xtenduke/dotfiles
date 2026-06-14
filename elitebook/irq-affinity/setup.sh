#!/bin/bash
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"

install -m 755 "$DIR/irq-affinity.sh" /usr/local/bin/irq-affinity.sh
install -m 644 "$DIR/irq-affinity.service" /etc/systemd/system/

systemctl daemon-reload
systemctl enable --now irq-affinity.service
echo "Installed irq-affinity.service"
