#!/bin/bash
# Migrates IRQs for high-throughput devices to LP E-cores.
# This keeps P-cores and regular E-cores in deeper sleep states while idle.
#
# LP E-cores are auto-detected as the CPUs with the lowest max frequency.
# On Intel Core Ultra (Meteor Lake), these are typically the last 2 CPUs.
set -e
# IRQ affinity writes can fail for managed IRQs (kernel-controlled MSI-X vectors).
# Those failures are expected and harmless — skip them.

_get_lp_ecores() {
    # Find CPUs with the lowest max frequency — those are the LP E-cores.
    local min_max_freq
    min_max_freq=$(cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq 2>/dev/null | sort -n | head -1)

    local cpus=()
    for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/cpuinfo_max_freq; do
        local freq
        freq=$(cat "$cpu_dir")
        if [[ "$freq" == "$min_max_freq" ]]; then
            local cpu_num
            cpu_num=$(echo "$cpu_dir" | grep -o 'cpu[0-9]*' | grep -o '[0-9]*' | head -1)
            cpus+=("$cpu_num")
        fi
    done

    local sorted
    sorted=$(printf '%s\n' "${cpus[@]}" | sort -n)
    local first last
    first=$(echo "$sorted" | head -1)
    last=$(echo "$sorted" | tail -1)
    echo "${first}-${last}"
}

LP_CORES=$(_get_lp_ecores)
echo "LP E-cores detected: $LP_CORES"

_pin_irq() {
    local pattern="$1"
    grep -i "$pattern" /proc/interrupts | awk -F: '{print $1}' | tr -d ' ' | while read -r irq; do
        if [[ -f "/proc/irq/$irq/smp_affinity_list" ]]; then
            if echo "$LP_CORES" > "/proc/irq/$irq/smp_affinity_list" 2>/dev/null; then
                echo "  irq $irq ($pattern) -> $LP_CORES"
            else
                echo "  irq $irq ($pattern) -> skipped (managed IRQ)"
            fi
        fi
    done
}

echo "Pinning IRQs to LP E-cores ($LP_CORES)..."
_pin_irq "nvme"
_pin_irq "iwlwifi"
_pin_irq "AudioDSP"
_pin_irq "snd_hda"
# Note: Meteor Lake uses the xe driver, not i915 — xe IRQs if present:
_pin_irq "xe"

echo "Done."
