#!/usr/bin/env bash
# ==============================================================================
# KernelSU-Next & SUSFS Integrator for Linux 4.19 (Exynos 850)
# ==============================================================================

set -uo pipefail

KERNEL_DIR="${1:-.}"
cd "$KERNEL_DIR"

echo "[*] Setting up KernelSU-Next / KernelSU in $KERNEL_DIR..."

# Clean up broken symlinks if any
rm -rf drivers/kernelsu KernelSU 2>/dev/null || true

echo "[+] Cloning KernelSU-Next..."
if ! git clone --depth=1 https://github.com/KernelSU-Next/KernelSU-Next.git -b next KernelSU 2>/dev/null; then
    echo "[!] Fallback: Cloning upstream KernelSU..."
    git clone --depth=1 https://github.com/tiann/KernelSU.git KernelSU
fi

# Physically copy kernel/ contents directly into drivers/kernelsu
mkdir -p drivers/kernelsu
cp -r KernelSU/kernel/* drivers/kernelsu/

# Verify Kconfig exists
if [ -f "drivers/kernelsu/Kconfig" ]; then
    echo "[✓] drivers/kernelsu/Kconfig successfully placed."
else
    echo "[!] Error: drivers/kernelsu/Kconfig could not be created!"
    exit 1
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
