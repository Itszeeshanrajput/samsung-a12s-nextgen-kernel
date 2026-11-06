#!/usr/bin/env bash
# ==============================================================================
# Exynos 850 Defconfig Optimizer & Feature Injector
# Target: Samsung Galaxy A12 Nacho (SM-A127F / universal3830 / a12s)
# ==============================================================================

set -euo pipefail

DEFCONFIG_FILE="${1:-arch/arm64/configs/universal3830_defconfig}"

if [ ! -f "$DEFCONFIG_FILE" ]; then
    echo "[!] Error: Defconfig not found at $DEFCONFIG_FILE"
    exit 1
fi

echo "[*] Optimizing defconfig: $DEFCONFIG_FILE"

# Function to enforce / update config flags
set_config() {
    local key="$1"
    local val="$2"
    if grep -q "^${key}=" "$DEFCONFIG_FILE"; then
        sed -i "s|^${key}=.*|${key}=${val}|" "$DEFCONFIG_FILE"
    elif grep -q "^# ${key} is not set" "$DEFCONFIG_FILE"; then
        sed -i "s|^# ${key} is not set|${key}=${val}|" "$DEFCONFIG_FILE"
    else
        echo "${key}=${val}" >> "$DEFCONFIG_FILE"
    fi
}

disable_config() {
    local key="$1"
    if grep -q "^${key}=" "$DEFCONFIG_FILE"; then
        sed -i "s|^${key}=.*|# ${key} is not set|" "$DEFCONFIG_FILE"
    elif ! grep -q "^# ${key} is not set" "$DEFCONFIG_FILE"; then
        echo "# ${key} is not set" >> "$DEFCONFIG_FILE"
    fi
}

echo "[+] 1. Disabling Samsung Knox / DEFEX / RKP latency bloat..."
disable_config "CONFIG_SECURITY_DEFEX"
disable_config "CONFIG_KNOX_KAP"
disable_config "CONFIG_TIMA"
disable_config "CONFIG_RKP_KDP"
disable_config "CONFIG_SAMSUNG_FREECESS"
disable_config "CONFIG_SEC_DEBUG"
disable_config "CONFIG_SEC_RESTRICT_ROOTING"
disable_config "CONFIG_SEC_RESTRICT_SETUID"

echo "[+] 2. Enabling Advanced ZRAM with ZSTD Memory Compression..."
set_config "CONFIG_ZRAM" "y"
set_config "CONFIG_ZRAM_WRITEBACK" "y"
set_config "CONFIG_CRYPTO_ZSTD" "y"
set_config "CONFIG_ZSTD_COMPRESS" "y"
set_config "CONFIG_ZSTD_DECOMPRESS" "y"
set_config "CONFIG_ZRAM_DEF_COMP_ZSTD" "y"
set_config "CONFIG_SWAP" "y"

echo "[+] 3. Enabling In-Kernel WireGuard VPN..."
set_config "CONFIG_WIREGUARD" "y"
set_config "CONFIG_NET_UDP_TUNNEL" "y"
set_config "CONFIG_DST_CACHE" "y"

echo "[+] 4. Enabling TCP BBR Congestion Control..."
set_config "CONFIG_TCP_CONG_BBR" "y"
set_config "CONFIG_DEFAULT_TCP_CONG" '"bbr"'
set_config "CONFIG_NET_SCH_FQ" "y"

echo "[+] 5. Enabling KernelSU & Modern Root Hooks..."
set_config "CONFIG_KSU" "y"
set_config "CONFIG_KSU_SUSFS" "y"
set_config "CONFIG_OVERLAY_FS" "y"
set_config "CONFIG_KALLSYMS" "y"
set_config "CONFIG_KALLSYMS_ALL" "y"

echo "[+] 6. Tuning CPU Scheduler & Performance..."
set_config "CONFIG_CPU_FREQ_GOV_SCHEDUTIL" "y"
set_config "CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL" "y"
set_config "CONFIG_SCHED_TUNE" "y"
set_config "CONFIG_ENERGY_MODEL" "y"

echo "[✓] Defconfig successfully optimized for Next-Gen Exynos 850 build!"
