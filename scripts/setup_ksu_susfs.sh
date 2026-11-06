#!/usr/bin/env bash
# ==============================================================================
# KernelSU-Next & SUSFS Integrator for Linux 4.19 (Exynos 850)
# ==============================================================================

set -uo pipefail

KERNEL_DIR="${1:-.}"
cd "$KERNEL_DIR"

echo "[*] Setting up KernelSU-Next / KernelSU in $KERNEL_DIR..."

# In ametoxg/a12s_kernel, drivers/kernelsu is a symlink pointing to ../KernelSU
if [ -d "KernelSU" ]; then
    echo "[*] KernelSU directory already present."
else
    echo "[+] Cloning KernelSU-Next at repository root..."
    if ! git clone --depth=1 https://github.com/KernelSU-Next/KernelSU-Next.git -b next KernelSU 2>/dev/null; then
        echo "[!] Fallback: Cloning upstream KernelSU..."
        git clone --depth=1 https://github.com/tiann/KernelSU.git KernelSU
    fi
fi

# Ensure drivers/kernelsu symlink points to KernelSU
rm -rf drivers/kernelsu 2>/dev/null || true
ln -sfn ../KernelSU drivers/kernelsu

# Verify Kconfig exists
if [ -f "drivers/kernelsu/Kconfig" ]; then
    echo "[✓] drivers/kernelsu/Kconfig confirmed accessible."
else
    echo "[!] Warning: drivers/kernelsu/Kconfig not found, copying directly..."
    mkdir -p drivers/kernelsu
    cp -r KernelSU/* drivers/kernelsu/
fi

# Ensure drivers/Makefile includes kernelsu
if grep -q "CONFIG_KSU" drivers/Makefile 2>/dev/null; then
    echo "[*] drivers/Makefile already configured for KSU."
else
    echo "obj-\$(CONFIG_KSU) += kernelsu/" >> drivers/Makefile
fi

# SUSFS hooks
if [ -f "fs/susfs.c" ] && ! grep -q "susfs.o" fs/Makefile; then
    echo "obj-y += susfs.o" >> fs/Makefile
fi

echo "[✓] KernelSU & SUSFS integration setup complete."
