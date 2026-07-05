#!/bin/bash
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"

install -m 644 "$DIR/50-usb-input-power.rules" /etc/udev/rules.d/
udevadm control --reload-rules
udevadm trigger --action=add --subsystem-match=usb

# Apply immediately to already-connected devices (udev trigger only fires on future hotplug)
for dev in /sys/bus/usb/devices/*/; do
    vendor=$(cat "$dev/idVendor" 2>/dev/null)
    product=$(cat "$dev/idProduct" 2>/dev/null)
    case "$vendor:$product" in
        7432:0658|046d:c539)
            echo on > "$dev/power/control" 2>/dev/null \
                && echo "  Set $vendor:$product [$(cat "$dev/product" 2>/dev/null)] to on"
            ;;
    esac
done

echo "Installed udev rules and triggered reload."
echo "Verify with:"
echo "  cat /sys/bus/usb/devices/*/power/control | sort | uniq -c"
