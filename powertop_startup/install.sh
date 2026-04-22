#!/bin/bash
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root"
    exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing powertop startup service"

cp "$DIR/startup_script.sh" /usr/bin/
cp "$DIR/powertop_startup.service" /etc/systemd/system/

systemctl daemon-reload
systemctl enable powertop_startup
