#!/usr/bin/env bash
# ==============================================================================
# Touch Polling Rate Boost Engine (180Hz / 240Hz) for Exynos 850 (SM-A127F)
# ==============================================================================

set -euo pipefail

KERNEL_DIR="${1:-.}"
cd "$KERNEL_DIR"

echo "[*] Optimizing touch driver polling rate for gaming responsiveness..."

TOUCH_DIR="drivers/input/touchscreen"

# Find Samsung / Synaptics / Goodix touch drivers
find "$TOUCH_DIR" -name "*.c" -o -name "*.h" | while read -r touch_file; do
    if grep -q "report_rate" "$touch_file" 2>/dev/null; then
        echo "[+] Boosting report rate in $touch_file..."
        sed -i -E 's/report_rate\s*=\s*[0-9]+/report_rate = 240/g' "$touch_file"
    fi
    if grep -q "sampling_freq" "$touch_file" 2>/dev/null; then
        echo "[+] Boosting sampling frequency in $touch_file..."
        sed -i -E 's/sampling_freq\s*=\s*[0-9]+/sampling_freq = 240/g' "$touch_file"
    fi
done

echo "[✓] Touch polling rate optimizations injected."
