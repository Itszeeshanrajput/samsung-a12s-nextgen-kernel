#!/usr/bin/env bash
# ==============================================================================
# KernelSU-Next & SUSFS Integrator for Linux 4.19 (Exynos 850)
# ==============================================================================

set -euo pipefail

KERNEL_DIR="${1:-.}"
cd "$KERNEL_DIR"

echo "[*] Setting up KernelSU-Next / KernelSU in $KERNEL_DIR..."

if [ ! -d "drivers/kernelsu" ] && [ ! -d "KernelSU" ]; then
    echo "[+] Fetching KernelSU-Next..."
    # Support both KernelSU-Next and upstream KernelSU fallback
    if curl -sSf "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next; then
        echo "[✓] KernelSU-Next successfully cloned and linked."
    else
        echo "[!] KernelSU-Next fetch failed, attempting upstream KernelSU..."
        curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
        echo "[✓] Upstream KernelSU linked."
    fi
else
    echo "[*] KernelSU directory already present, updating..."
    if [ -d "KernelSU" ]; then
        cd KernelSU && git pull && cd ..
    elif [ -d "drivers/kernelsu" ]; then
        cd drivers/kernelsu && git pull && cd ..
    fi
fi

echo "[*] Integrating SUSFS (Super User Screen File System) support hooks..."
# Ensure fs/Makefile includes susfs if patch is applied
if [ -f "fs/susfs.c" ] && ! grep -q "susfs.o" fs/Makefile; then
    echo "obj-y += susfs.o" >> fs/Makefile
fi

echo "[✓] KernelSU & SUSFS integration setup complete."
