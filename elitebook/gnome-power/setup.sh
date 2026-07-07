#!/bin/bash
# GNOME power tweaks — run as your regular user (not root).
#
# Key win: disabling cursor blink stops the GPU waking from PSR sleep ~60x/sec.
set -e

if [[ "$EUID" -eq 0 ]]; then
    echo "Run as your regular user, not root"
    exit 1
fi

# Cursor blink wakes GPU from deep sleep on every blink cycle
gsettings set org.gnome.desktop.interface cursor-blink false

# Disable animations (minor GPU savings)
gsettings set org.gnome.desktop.interface enable-animations false

# Screen idle / auto-suspend timings
gsettings set org.gnome.desktop.session idle-delay 300
gsettings set org.gnome.settings-daemon.plugins.power idle-dim true
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'

# Stop gnome-software from waking up to check for updates in the background
gsettings set org.gnome.software download-updates false
gsettings set org.gnome.software allow-updates false

# Mask gnome-software autostart (runs as user service)
systemctl --user mask gnome-software-service.service 2>/dev/null || true

echo "GNOME power settings applied"
echo ""
echo "If using Ptyxis terminal, also run:"
echo "  dconf write /org/gnome/Ptyxis/cursor-blink-mode \"'off'\""
