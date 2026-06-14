#!/bin/bash
# Writes LTR ignore values to silence devices that block S0ix deep sleep.
# Run ltr-discover.sh to find the right indices for your machine.
#
# Blog reference used indices 1, 3, 6, 25, 40 on a Fujitsu Lifebook.
# These WILL differ on the EliteBook — run ltr-discover.sh first.
set -e

LTR_IGNORE="/sys/kernel/debug/pmc_core/ltr_ignore"

# ── CONFIGURE THESE per-machine ──────────────────────────────────────────────
# EliteBook 840 G11 (Core Ultra 5 125U):
#   17 = PMC0:ISH        (Integrated Sensor Hub — touchpad/sensors, ~10.5ms)
#   25 = PMC0:IOE_PMC    (I/O Expansion domain PMC — LP E-core side, ~5.6ms)
# Run ltr-discover.sh on a new machine to find the correct values.
LTR_IGNORE_INDICES=(17 25)
# ─────────────────────────────────────────────────────────────────────────────

if [[ ! -f "$LTR_IGNORE" ]]; then
    echo "Warning: $LTR_IGNORE not found — skipping LTR ignore setup"
    exit 0
fi

for idx in "${LTR_IGNORE_INDICES[@]}"; do
    echo "$idx" > "$LTR_IGNORE"
    echo "ltr_ignore: wrote $idx"
done
