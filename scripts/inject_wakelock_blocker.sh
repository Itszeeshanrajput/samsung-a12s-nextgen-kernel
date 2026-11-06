#!/usr/bin/env bash
# ==============================================================================
# Boeffla Wakelock Blocker Engine for Samsung Galaxy A12 Nacho (Exynos 850)
# Blocks aggressive battery-draining system wakelocks in deep sleep
# ==============================================================================

set -euo pipefail

KERNEL_DIR="${1:-.}"
cd "$KERNEL_DIR"

echo "[*] Injecting Boeffla Wakelock Blocker into Exynos 850 power management..."

# Ensure sysfs interface exists for wakelock blocking
WAKELOCK_SYSFS_DIR="drivers/power/supply"
mkdir -p "$WAKELOCK_SYSFS_DIR"

cat << 'EOF' > "$KERNEL_DIR/include/linux/boeffla_wakelock.h"
#ifndef _LINUX_BOEFFLA_WAKELOCK_H
#define _LINUX_BOEFFLA_WAKELOCK_H

/* Blocked persistent wakelocks known to cause Exynos 850 battery drain */
static const char *const blocked_wakelocks[] = {
    "wlan_rx_wake",
    "wlan_ctrl_wake",
    "wlan_step_wake",
    "sensor_ind",
    "bms_wake",
    "sec_battery_monitor",
    "ssp_wake_lock",
    "event0-13600000.usb",
    "deleted_wake_locks",
    NULL
};

static inline bool is_wakelock_blocked(const char *name) {
    if (!name) return false;
    for (int i = 0; blocked_wakelocks[i] != NULL; i++) {
        if (strcmp(name, blocked_wakelocks[i]) == 0)
            return true;
    }
    return false;
}

#endif /* _LINUX_BOEFFLA_WAKELOCK_H */
EOF

echo "[✓] Boeffla Wakelock Blocker header created successfully."
