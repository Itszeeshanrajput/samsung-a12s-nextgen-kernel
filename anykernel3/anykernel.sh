### AnyKernel3 Packaging Script for Samsung Galaxy A12 Nacho (SM-A127F / a12s)
### Target SoC: Samsung Exynos 850 (universal3830)

properties() { '
kernel.string=NextGen Kernel for Samsung Galaxy A12 Nacho (SM-A127F)
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
supported.versions=11, 12, 12.1, 13, 14
supported.patchlevels=
'; }

### AnyKernel setup
block=/dev/block/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

## AnyKernel methods (DO NOT CHANGE)
# import functions/variables and setup patching environment
. tools/ak3-core.sh;

## AnyKernel boot install
split_boot;

# Samsung KNOX & dm-verity bypass flags in cmdline if needed
# remove_cmdline_param androidboot.selinux;

flash_boot;
## end boot install
