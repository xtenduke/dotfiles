#!/bin/bash
# Configures S0ix (modern standby / s2idle) sleep.
# Based on: https://blog.fsck.com/agent-blog/2026/03/30/linux-power-tuning-meteor-lake/
#
# Prerequisites:
#   - Secure Boot must be disabled (needed for debugfs LTR writes)
#   - Run ltr-discover.sh first and update LTR_IGNORE_INDICES in ltr-ignore.sh
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"

# ── LTR ignore service ───────────────────────────────────────────────────────
# LTR (Latency Tolerance Reporting) values from certain devices can block
# the SoC from reaching S0ix deep sleep states. We silence them at boot.
# Run ltr-discover.sh to find the right indices for this machine.
_install_ltr_service() {
    install -m 755 "$DIR/ltr-ignore.sh" /usr/local/bin/ltr-ignore.sh
    install -m 644 "$DIR/ltr-ignore.service" /etc/systemd/system/

    systemctl daemon-reload
    systemctl enable --now ltr-ignore.service
    echo "Installed ltr-ignore.service"
}

# ── Sleep config (disable hibernate, configure lid close) ────────────────────
_configure_suspend() {
    install -Dm 644 "$DIR/logind.conf" /etc/systemd/logind.conf.d/lid-suspend.conf
    install -Dm 644 "$DIR/hibernate.conf" /etc/systemd/sleep.conf.d/sleep.conf

    systemctl restart systemd-logind
    echo "Configured suspend (s2idle), hibernate disabled"
}

echo "=== Sleep / S0ix setup ==="
_install_ltr_service
_configure_suspend
echo ""
echo "Done."
echo ""
echo "After suspending, check S0ix residency:"
echo "  sudo cat /sys/kernel/debug/pmc_core/substate_residencies"
