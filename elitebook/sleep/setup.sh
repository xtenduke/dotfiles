#!/bin/bash
# Configures S0ix (modern standby) + suspend-then-hibernate
# Based on: https://blog.fsck.com/agent-blog/2026/03/30/linux-power-tuning-meteor-lake/
#
# Prerequisites:
#   - Secure Boot must be disabled (needed for debugfs LTR writes)
#   - Swap >= RAM size (already configured at /swap/swapfile)
#   - Run ltr-discover.sh first and set LTR_INDICES below
#
# Before running, check LTR blocking:
#   sudo ./ltr-discover.sh
# Then set the indices that show as blocking in LTR_IGNORE_INDICES below.
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Hibernate resume params ──────────────────────────────────────────────────
# These tell the kernel where the swap file lives so it can resume from hibernate.
# Compute the physical offset of the swap file for the kernel resume_offset param.
_setup_hibernate_resume() {
    local swapfile="/swap/swapfile"
    local uuid
    uuid=$(findmnt -no UUID -T "$swapfile")

    # btrfs needs btrfs inspect; ext4/xfs can use filefrag
    local fs_type
    fs_type=$(findmnt -no FSTYPE -T "$swapfile")

    local offset
    if [[ "$fs_type" == "btrfs" ]]; then
        offset=$(btrfs inspect-internal map-swapfile -r "$swapfile" | awk '{print $NF}')
    else
        offset=$(filefrag -v "$swapfile" | awk 'NR==4{gsub(/\./,"",$4); print $4}')
    fi

    echo "Swap UUID:   $uuid"
    echo "Swap offset: $offset"
    echo "Filesystem:  $fs_type"

    grubby --update-kernel=ALL --args="resume=UUID=$uuid resume_offset=$offset"
    echo "Added resume params to kernel cmdline"
}

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

# ── Suspend-then-hibernate (lid close / idle) ────────────────────────────────
_configure_suspend() {
    install -Dm 644 "$DIR/logind.conf" /etc/systemd/logind.conf.d/lid-suspend.conf
    install -Dm 644 "$DIR/hibernate.conf" /etc/systemd/sleep.conf.d/hibernate.conf

    systemctl restart systemd-logind
    echo "Configured suspend-then-hibernate"
}

# ── SELinux policy for suspend-then-hibernate ────────────────────────────────
# Fedora 44: systemd_sleep_t is denied write on init_var_lib_t, breaking
# suspend-then-hibernate. Apply a local policy module to permit it.
_install_selinux_policy() {
    local pp="$DIR/systemd-sleep-fix.pp"
    local te="$DIR/systemd-sleep-fix.te"
    if ! semodule -l 2>/dev/null | grep -q "systemd-sleep-fix"; then
        if [[ -f "$pp" ]]; then
            semodule -X 300 -i "$pp"
            echo "Installed SELinux policy: systemd-sleep-fix"
        elif [[ -f "$te" ]]; then
            cd /tmp
            checkmodule -M -m -o systemd-sleep-fix.mod "$te"
            semodule_package -o systemd-sleep-fix.pp -m systemd-sleep-fix.mod
            semodule -X 300 -i /tmp/systemd-sleep-fix.pp
            echo "Built and installed SELinux policy: systemd-sleep-fix"
        else
            echo "Warning: systemd-sleep-fix.pp not found — skipping SELinux policy"
        fi
    else
        echo "SELinux policy systemd-sleep-fix already installed"
    fi
}

echo "=== Sleep / S0ix setup ==="
_setup_hibernate_resume
_install_ltr_service
_configure_suspend
_install_selinux_policy
echo ""
echo "Done. Reboot for kernel cmdline changes to take effect."
echo ""
echo "After reboot, check S0ix residency after a suspend:"
echo "  sudo cat /sys/kernel/debug/pmc_core/substate_residencies"
