#!/bin/bash
# Installs the RP11 _S0W=4 ACPI SSDT override for S0ix (modern standby).
#
# _S0W=4 tells the kernel D3cold is acceptable for RP11 (the PCIe root port
# hosting the NVMe). The Meteor Lake PMC handles PCIe link L23 transitions
# autonomously during s2idle — _PR3/DL23 are not needed and cause boot failures
# because bridge_d3=true triggers immediate D3cold from the PCIe port driver
# before the nvme driver has probed.
#
# If boot hangs: at GRUB press 'e', change initrd to
# /initramfs-$(uname -r).img.acpi-rp11-pre, press F10.
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
DSL="$DIR/rp11-d3cold.dsl"
KVER="$(uname -r)"
INITRAMFS="/boot/initramfs-${KVER}.img"
BACKUP="${INITRAMFS}.acpi-rp11-pre"
KINST_DIR="/usr/lib/kernel/install.d"
KINST_SCRIPT="$KINST_DIR/90-acpi-rp11-d3cold.install"
AML_SYSTEM="/usr/lib/firmware/acpi/rp11-d3cold.aml"

# Compile
echo "Compiling..."
iasl -p "$DIR/rp11-d3cold" "$DSL"
AML_SRC="$DIR/rp11-d3cold.aml"

# Build CPIO (SSDT only — no udev/systemd workarounds needed)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/kernel/firmware/acpi"
cp "$AML_SRC" "$WORK/kernel/firmware/acpi/rp11-d3cold.aml"

(cd "$WORK" && find kernel | sort | cpio -H newc --create --quiet) > "$WORK/acpi-override.cpio"

# Clean initramfs rebuild, then back up, then prepend CPIO.
echo "Rebuilding initramfs..."
dracut --force
rm -f "$BACKUP"
cp "$INITRAMFS" "$BACKUP"
echo "Backed up to $BACKUP"

cat "$WORK/acpi-override.cpio" "$BACKUP" > "$INITRAMFS"
echo "Prepended CPIO to $INITRAMFS"

# Write revert.sh
cat > "$DIR/revert.sh" <<REVERT
#!/bin/bash
set -e
KVER="\$(uname -r)"
INITRAMFS="/boot/initramfs-\${KVER}.img"
BACKUP="\${INITRAMFS}.acpi-rp11-pre"
[ -f "\$BACKUP" ] && cp "\$BACKUP" "\$INITRAMFS" && rm "\$BACKUP" && echo "Restored initramfs" || dracut --force
rm -f "$KINST_SCRIPT" "$AML_SYSTEM"
echo "Done. Reboot."
REVERT
chmod +x "$DIR/revert.sh"

# kernel-install plugin for future kernel updates
mkdir -p "$(dirname "$AML_SYSTEM")"
cp "$AML_SRC" "$AML_SYSTEM"
cat > "$KINST_SCRIPT" <<'KINST'
#!/bin/bash
[ "${1}" = "add" ] || exit 0
KVER="${2:?}"
INITRAMFS="/boot/initramfs-${KVER}.img"
[ -f "$INITRAMFS" ] || exit 0
AML="/usr/lib/firmware/acpi/rp11-d3cold.aml"
[ -f "$AML" ] || exit 1
WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/kernel/firmware/acpi"
cp "$AML" "$WORK/kernel/firmware/acpi/rp11-d3cold.aml"

(cd "$WORK" && find kernel | sort | cpio -H newc --create --quiet) > "$WORK/cpio"
cp "$INITRAMFS" "${INITRAMFS}.acpi-rp11-pre"
cat "$WORK/cpio" "${INITRAMFS}.acpi-rp11-pre" > "$INITRAMFS"
echo "acpi-rp11-d3cold: prepended CPIO to $INITRAMFS"
KINST
chmod +x "$KINST_SCRIPT"

echo ""
echo "Done. Reboot to activate."
echo "If boot hangs: at GRUB press 'e', change initrd to /initramfs-${KVER}.img.acpi-rp11-pre, F10."
echo "Then run: $DIR/revert.sh"
