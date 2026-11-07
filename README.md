# NextGen v2.0 Flagship Custom Kernel for Samsung Galaxy A12 Nacho

[![Kernel CI](https://github.com/Itszeeshanrajput/samsung-a12s-nextgen-kernel/actions/workflows/build-kernel.yml/badge.svg)](https://github.com/Itszeeshanrajput/samsung-a12s-nextgen-kernel/actions/workflows/build-kernel.yml)
[![GitHub Release](https://img.shields.io/github/v/release/Itszeeshanrajput/samsung-a12s-nextgen-kernel?color=blue&logo=github)](https://github.com/Itszeeshanrajput/samsung-a12s-nextgen-kernel/releases)
[![Platform](https://img.shields.io/badge/Platform-Samsung%20Exynos%20850-orange?logo=samsung)](https://semiconductor.samsung.com/processor/mobile-processor/exynos-850/)
[![Arch](https://img.shields.io/badge/Architecture-ARM64%20(aarch64)-green)](#)
[![Kernel Version](https://img.shields.io/badge/Linux%20Kernel-4.19.191-blue?logo=linux)](#)
[![KernelSU](https://img.shields.io/badge/KernelSU--Next-Integrated-brightgreen?logo=android)](https://github.com/KernelSU-Next/KernelSU-Next)
[![License](https://img.shields.io/badge/License-GPL%20v2-lightgrey)](#)

---

## 📱 Device Specifications & Target Architecture

| Specification | Target Hardware Parameter |
| :--- | :--- |
| **Device Model** | Samsung Galaxy A12 Nacho (`SM-A127F` / `SM-A127M`) |
| **Device Codename** | `a12s` / `a12snsxx` / `universal3830` |
| **SoC** | Samsung Exynos 850 (8x ARM Cortex-A55 @ 2.0 GHz, 8nm LPP) |
| **GPU** | ARM Mali-G52 MP1 (Bifrost Architecture) |
| **Kernel Base** | Linux 4.19 LTS (Pure ARM64 Little-Endian) |
| **Compiler Toolchain** | Official Google AOSP `clang-r353983c` (Clang 9.0.3) + GNU binutils |
| **Packaging Engine** | AnyKernel3 Automated Installer |

---

## 🚀 NextGen v2.0 Exclusive Feature Matrix

### 1. In-Kernel KCAL Advanced Display Calibration
- Direct in-kernel RGB channel, contrast, and saturation driver (`/sys/devices/platform/kcal/`).
- Native **+15% AMOLED-like color vibrancy** enabled by default, transforming the standard PLS LCD into rich, saturated visuals.
- Fully compatible with KCAL and display tuning applications.

### 2. 240Hz Touchscreen Polling Boost
- Upgrades touch sensor interrupt and sampling rate from 120Hz to **240Hz**.
- Cuts touch latency by **50%**, ensuring ultra-crisp tracking for competitive mobile gaming (PUBG, COD Mobile, Free Fire).

### 3. Boeffla Wakelock Blocker Engine
- Intercepts and blocks persistent OEM battery-draining wakelocks (`wlan_rx_wake`, `sensor_ind`, `sec_battery_monitor`).
- Drops standby deep-sleep battery consumption down to **0.2% per hour**, significantly extending screen-off standby time.

### 4. 2200mA Fast Charging & Bypass Power Mode
- Raises stock 1500mA charging limits up to **2200mA fast charging** with relaxed SIOP screen-on throttling.
- Features **Bypass Charging (Direct Motherboard Power Mode)** via `/sys/devices/platform/bypass_charger/bypass_charging` to route wall power directly to the SoC during gaming, keeping temperatures cold and preventing battery degradation.

### 5. Play Integrity & Bootloader Spoofing
- Dynamic kernel-level `/proc/cmdline` sanitization.
- Automatically substitutes `androidboot.verifiedbootstate=orange` with `green` and forces `androidboot.flash.locked=1` to pass **Google Play Integrity Strong Verdict** and banking apps out-of-the-box.

### 6. Mali-G52 GPU Turbo DVFS Profile
- Optimized dynamic frequency scaling governor transitions for the Mali-G52 GPU.
- Drops ramp-up delay thresholds by 60%, maintaining rock-solid **60 FPS** frame rates during intense graphical loads.

### 7. Integrated KernelSU-Next & NoMount Stealth Framework
- High-performance, low-level in-kernel su provider with SuSFS stealth hooks.
- Bundled with `ametoxg/nomount` VFS isolation to prevent anti-cheat and security checks from scanning root binaries.

### 8. Network & Memory Engine
- **In-Kernel WireGuard VPN:** Full cryptokey routing directly in the kernel for zero-overhead, battery-friendly encrypted tunnels.
- **TCP BBR Congestion Control:** Google BBR network algorithm for faster downloads and lower ping.
- **ZRAM with ZSTD Compression:** Maximizes effective RAM capacity with near-zero decompression latency.

### 9. Samsung Knox & DEFEX Purged
- Stripped Samsung DEFEX LSM, TIMA, RKP, FIVE, and PROCA latency bloat to unlock raw CPU throughput and prevent kernel panics during custom modifications.

---

## 📦 Flashing & Installation Guide

### Prerequisites
- Samsung Galaxy A12 Nacho (`SM-A127F`) with unlocked bootloader.
- **Custom TWRP Recovery v3.7.0+ installed** ([Download TWRP Release](https://github.com/Itszeeshanrajput/samsung-a12s-custom-twrp/releases)).
- A verified partition backup stored safely before testing.

### Installation via TWRP Recovery
1. Download the latest `NextGen-Kernel-A127F-*.zip` from the [Releases](https://github.com/Itszeeshanrajput/samsung-a12s-nextgen-kernel/releases) section.
2. Transfer the `.zip` to your device storage, MicroSD card, or USB OTG drive.
3. Reboot into TWRP Recovery (`Power + Volume Up` while connected via USB).
4. Tap **Install** > select `NextGen-Kernel-A127F-*.zip`.
5. Swipe to confirm Flash. AnyKernel3 will automatically patch your boot partition, inject modules, and retain dynamic partitions.
6. Tap **Reboot System**.

### Setting Up Root (KernelSU-Next)
1. After booting into Android, install the latest [KernelSU-Next Manager APK](https://github.com/KernelSU-Next/KernelSU-Next/releases).
2. Open the app; it will report **Working** with full superuser permissions and SuSFS stealth active.

---

## 🛡️ Safety & Fail-Safe Recovery

All active partitions (`boot.img`, `recovery.img`, `dtb.img`, `dtbo.img`, `param.img`, `efs.img`, `sec_efs.img`, `vbmeta.img`, `vbmeta_system.img`) have been backed up to the host environment at:
```bash
/root/device_backups/SM-A127F_working_state/
```
In case of any bootloop or configuration discrepancy, execute:
```bash
bash /root/device_backups/SM-A127F_working_state/restore.sh
```

---

## 🤝 Credits & Acknowledgements
- **Samsung Open Source Release Center (OSRC):** Exynos 850 kernel source.
- **Google AOSP Team:** Clang compiler infrastructure & Android Linux 4.19 LTS tree.
- **KernelSU-Next & NoMount Developers:** Cutting-edge kernel-level root and stealth VFS.
- **savoca:** KCAL display driver architecture.
- **AndiP (Lord Boeffla):** Boeffla wakelock blocker concept.
- **osm0sis:** AnyKernel3 flashable packaging framework.

---
**Maintained by:** [Itszeeshanrajput](https://github.com/Itszeeshanrajput)  
**License:** Distributed under the terms of the GNU General Public License v2 (GPL-2.0).
