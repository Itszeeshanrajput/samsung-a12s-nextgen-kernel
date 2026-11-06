#!/usr/bin/env bash
# ==============================================================================
# KernelSU-Next & SUSFS Integrator for Linux 4.19 (Exynos 850)
# ==============================================================================

set -euo pipefail

KERNEL_DIR="${1:-.}"
cd "$KERNEL_DIR"

echo "[*] Setting up KernelSU-Next / KernelSU in $KERNEL_DIR..."

mkdir -p drivers/kernelsu

if [ ! -f "drivers/kernelsu/Kconfig" ]; then
    echo "[+] Fetching KernelSU-Next into drivers/kernelsu..."
    if ! git clone --depth=1 https://github.com/KernelSU-Next/KernelSU-Next.git -b next drivers/kernelsu 2>/dev/null; then
        echo "[!] Fallback to upstream KernelSU..."
        git clone --depth=1 https://github.com/tiann/KernelSU.git drivers/kernelsu
    fi
    echo "[✓] KernelSU cloned into drivers/kernelsu."
fi

# Ensure drivers/Makefile includes kernelsu
if grep -q "CONFIG_KSU" drivers/Makefile 2>/dev/null; then
    echo "[*] drivers/Makefile already configured for KSU."
else
    echo "obj-\$(CONFIG_KSU) += kernelsu/" >> drivers/Makefile
fi

echo "[*] Integrating SUSFS (Super User Screen File System) support hooks..."
if [ -f "fs/susfs.c" ] && ! grep -q "susfs.o" fs/Makefile; then
    echo "obj-y += susfs.o" >> fs/Makefile
fi

echo "[✓] KernelSU & SUSFS integration setup complete."
