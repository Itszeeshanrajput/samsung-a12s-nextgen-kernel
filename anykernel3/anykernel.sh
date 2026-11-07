### AnyKernel3 Packaging Script for Samsung Galaxy A12 Nacho (SM-A127F / a12s)
### Target SoC: Samsung Exynos 850 (universal3830)

properties() { '
kernel.string=NextGen Kernel v2.0 for Samsung Galaxy A12 Nacho (SM-A127F)
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=a12s
device.name2=SM-A127F
device.name3=a12sxx
device.name4=SM-A127M
device.name5=SM-A127F/DS
supported.versions=
supported.patchlevels=
'; }

### AnyKernel setup
BLOCK=/dev/block/by-name/boot;
block=boot;
IS_SLOT_DEVICE=0;
is_slot_device=0;
RAMDISK_COMPRESSION=auto;
ramdisk_compression=auto;
PATCH_VBMETA_FLAG=auto;
patch_vbmeta_flag=auto;

## AnyKernel methods (DO NOT CHANGE)
# import functions/variables and setup patching environment
. tools/ak3-core.sh;

## AnyKernel boot install
split_boot;

# Preserve device's native Samsung DTB to prevent 'dt load failed' bootloader rejection
flash_boot;
## end boot install
