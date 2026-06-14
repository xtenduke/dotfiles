#!/bin/bash
# Reads the PMC LTR show table and identifies entries with non-zero values.
# These are candidates for ltr_ignore — blocking devices preventing S0ix.
#
# Usage:
#   sudo ./ltr-discover.sh
#
# After identifying blocking entries, add their index numbers to
# LTR_IGNORE_INDICES in ltr-ignore.sh.
set -e

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo $0"
    exit 1
fi

LTR_SHOW="/sys/kernel/debug/pmc_core/ltr_show"

if [[ ! -f "$LTR_SHOW" ]]; then
    echo "Error: $LTR_SHOW not found. Is debugfs mounted and pmc_core loaded?"
    exit 1
fi

echo "=== All LTR entries ==="
cat "$LTR_SHOW"

echo ""
echo "=== Entries with actual latency requirements (Non-Snoop or Snoop > 0 ns) ==="
# Match lines where the decoded ns value is non-zero (not just non-zero RAW)
awk -F'[[:space:]]+' '
  /Non-Snoop\(ns\):/ {
    # Extract the Non-Snoop ns value
    for (i=1; i<=NF; i++) {
      if ($i == "Non-Snoop(ns):") { ns = $(i+1) }
      if ($i == "Snoop(ns):") { snoop = $(i+1) }
    }
    if (ns+0 > 0 || snoop+0 > 0) print
  }
' "$LTR_SHOW" || echo "(none)"

echo ""
echo "=== Current ltr_ignore values ==="
cat /sys/kernel/debug/pmc_core/ltr_ignore 2>/dev/null || echo "(empty)"

echo ""
echo "To check which substates are being blocked:"
echo "  sudo cat /sys/kernel/debug/pmc_core/substate_requirements"
echo "  sudo cat /sys/kernel/debug/pmc_core/substate_residencies"
