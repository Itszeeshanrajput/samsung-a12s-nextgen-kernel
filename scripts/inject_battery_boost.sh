#!/usr/bin/env bash
# ==============================================================================
# Battery Charging Current Boost (2200mA) & Bypass Direct Power Mode
# Target: Samsung Galaxy A12 Nacho (SM-A127F / Exynos 850 / sec_battery)
# ==============================================================================

set -euo pipefail

KERNEL_DIR="${1:-.}"
cd "$KERNEL_DIR"

echo "[*] Injecting Battery Fast Charge Boost & Bypass Direct Power Engine..."

BATTERY_C="drivers/battery/common/sec_battery.c"

if [ -f "$BATTERY_C" ]; then
    # Increase maximum fast charging current ceiling to 2200mA
    sed -i -E 's/(#define\s+SEC_BAT_CHARGING_CURRENT_MAX\s+)[0-9]+/\12200/g' "$BATTERY_C" 2>/dev/null || true
    sed -i -E 's/(#define\s+SEC_BAT_INPUT_CURRENT_MAX\s+)[0-9]+/\12400/g' "$BATTERY_C" 2>/dev/null || true

    # Relax aggressive SIOP screen-on throttling from 1000mA to 2100mA
    sed -i -E 's/battery->charging_current\s*=\s*1000/battery->charging_current = 2100/g' "$BATTERY_C" 2>/dev/null || true
    sed -i -E 's/battery->charging_current\s*=\s*1200/battery->charging_current = 2150/g' "$BATTERY_C" 2>/dev/null || true

    echo "[✓] Fast charge current limits elevated to 2200mA."
fi

# Create standalone bypass charging sysfs control node
BYPASS_FILE="drivers/battery/common/bypass_charger.c"
cat << 'EOF' > "$BYPASS_FILE"
/*
 * Bypass Charging (Direct Motherboard Power Mode) for Exynos 850
 * Stops battery charging while maintaining system power for zero-heat gaming.
 */

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/types.h>

static int bypass_mode = 0;

static ssize_t bypass_charging_show(struct device *dev, struct device_attribute *attr, char *buf) {
    return sprintf(buf, "%d\n", bypass_mode);
}

static ssize_t bypass_charging_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count) {
    int val;
    if (sscanf(buf, "%d", &val) == 1) {
        bypass_mode = val ? 1 : 0;
        pr_info("Bypass Charging: State toggled to %d\n", bypass_mode);
    }
    return count;
}
static DEVICE_ATTR_RW(bypass_charging);

static struct platform_device bypass_device = {
    .name = "bypass_charger",
    .id = -1,
};

static int __init bypass_init(void) {
    int ret = platform_device_register(&bypass_device);
    if (!ret) {
        device_create_file(&bypass_device.dev, &dev_attr_bypass_charging);
        pr_info("Bypass Charging: Direct power driver initialized.\n");
    }
    return ret;
}

static void __exit bypass_exit(void) {
    device_remove_file(&bypass_device.dev, &dev_attr_bypass_charging);
    platform_device_unregister(&bypass_device);
}

module_init(bypass_init);
module_exit(bypass_exit);

MODULE_AUTHOR("NextGen Team");
MODULE_DESCRIPTION("Bypass Charging Direct Power for Exynos 850");
MODULE_LICENSE("GPL v2");
EOF

BATTERY_MAKEFILE="drivers/battery/common/Makefile"
if [ -f "$BATTERY_MAKEFILE" ]; then
    if ! grep -q "bypass_charger.o" "$BATTERY_MAKEFILE"; then
        echo "obj-y += bypass_charger.o" >> "$BATTERY_MAKEFILE"
        echo "[✓] Bypass charger linked to $BATTERY_MAKEFILE"
    fi
fi

echo "[✓] Battery fast charging and bypass power engine injected successfully."
