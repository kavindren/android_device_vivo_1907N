DEVICE_PATH := device/vivo/1907N

ALLOW_MISSING_DEPENDENCIES := true

# The dumped vendor.img ships prebuilt binaries/libs that collide by name with modules AOSP
# builds from source (e.g. vendor/bin/acpi) - standard, expected for MTK/OEM blob dumps and
# exactly what these flags exist for (same as device/xiaomi/mt6768-common sets).
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_PREBUILT_ELF_FILES := true

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a75

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a55

TARGET_BOARD_SUFFIX := _64
TARGET_USES_64_BIT_BINDER := true
TARGET_SUPPORTS_64_BIT_APPS := true
TARGET_IS_64_BIT := true

TARGET_BOARD_PLATFORM := mt6768
TARGET_BOARD_PLATFORM_GPU := mali-g52mc2

TARGET_BOOTLOADER_BOARD_NAME := k68v1_64
TARGET_NO_BOOTLOADER := true

BOARD_HAS_MTK_HARDWARE := true
BOARD_USES_MTK_HARDWARE := true
MTK_HARDWARE := true

TARGET_OTA_ASSERT_DEVICE := 1907N,vivo 1907,PD1913F_EX

BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 \
product.version=PD1913F_EX_A_9.10.0 \
fingerprint.abbr=12/SP1A.210812.003 \
region_ver=W20 \
product.solution=MTK \
androidboot.selinux=permissive
BOARD_KERNEL_BASE := 0x40078000
BOARD_PAGE_SIZE := 2048
BOARD_HASH_TYPE := sha1
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_KERNEL_RAMDISK_OFFSET := 0x07c08000
BOARD_KERNEL_SECOND_OFFSET := 0xbff88000
BOARD_TAGS_OFFSET := 0x0bc08000
BOARD_BOOT_HEADER_VERSION := 2
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_DTB_SIZE := 98357
BOARD_DTB_OFFSET := 0x0bc08000

BOARD_MKBOOTIMG_ARGS += --base $(BOARD_KERNEL_BASE)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_PAGE_SIZE)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_KERNEL_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --second_offset $(BOARD_KERNEL_SECOND_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)

BOARD_HAS_LARGE_FILESYSTEM := true
# Partition sizes must be decimal, not hex: build_image.py/verity_utils.py on this branch parses
# these fields with plain int(), no base=0 auto-detection, so a "0x..." literal throws
# "invalid literal for int() with base 10". The TWRP-only minimal manifest's build_image
# apparently tolerated hex; the full tree's doesn't. Values below are the exact same partition
# sizes (from MT6768_Android_scatter.txt), just decimal.
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_PARTITION_SIZE := 268435456
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 5905580032
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_PARTITION_SIZE := 115822526464
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_PARTITION_SIZE := 2147483648

BOARD_USES_VENDORIMAGE := true
TARGET_COPY_OUT_VENDOR := vendor

# Device shipped on Android 9 with static (non-dynamic) partitions: the scatter file has
# separate system/vendor partitions and no "super". Stock system.img/vendor.img dumps show
# product/system_ext folded under system/, and odm/odm_dlkm folded under vendor/ instead of
# living on their own physical partitions. Keep that layout for the full ROM build too.
TARGET_COPY_OUT_PRODUCT := system/product
TARGET_COPY_OUT_SYSTEM_EXT := system/system_ext
TARGET_COPY_OUT_ODM := vendor/odm
TARGET_COPY_OUT_ODM_DLKM := vendor/odm_dlkm
TARGET_COPY_OUT_VENDOR_DLKM := vendor/vendor_dlkm

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := false
BOARD_USES_RECOVERY_AS_BOOT := false

BOARD_BUILD_SYSTEM_ROOT_IMAGE := false
BOARD_SUPPRESS_SECURE_ERASE := true

# Kernel
BOARD_KERNEL_IMAGE_NAME := Image.gz
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64

# The final boot.img still uses the prebuilt Image.gz/dtb/dtbo above (same mechanism the
# working TWRP build already validated) - this is NOT building the kernel from source. It's
# only needed because vendor/lineage/build/soong's generated_kernel_includes module always
# wants a real kernel source tree to run `make headers_install` against, for UAPI headers used
# by native userspace code. Source lives at /home/kavindren/android_kernel_vivo_pd1913f,
# bind-mounted to kernel/vivo/1907N (same technique as the device/vivo/1907N bind mount).
TARGET_KERNEL_SOURCE := kernel/vivo/1907N

# Once TARGET_KERNEL_SOURCE resolves to a real tree, vendor/lineage/build/tasks/kernel.mk
# unconditionally requires TARGET_KERNEL_CONFIG and otherwise wants to build the kernel itself
# via a generic `make defconfig && make` using ITS OWN toolchain choice. That would NOT
# reproduce the already-working kernel: the real build (android_kernel_vivo_pd1913f/build.sh)
# pins a specific clang (r383902/v11.0.1) + GCC 4.9 combo for this 4.14 kernel, and its DTB goes
# through a custom post-processing step (wrap.py) that reconstructs the exact MTK Little Kernel
# header this device's bootloader expects - none of which the generic in-tree flow knows about.
# TARGET_KERNEL_CONFIG here is just to satisfy kernel.mk's bookkeeping (it's the defconfig
# build.sh actually uses); TARGET_FORCE_PREBUILT_KERNEL keeps kernel.mk from trying to drive its
# own build and makes it use TARGET_PREBUILT_KERNEL instead, same as before.
TARGET_KERNEL_CONFIG := pd1913f_defconfig
TARGET_FORCE_PREBUILT_KERNEL := true

TARGET_COPY_OUT_VENDOR := vendor

BOARD_AVB_ENABLE := true
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
# PLATFORM_SECURITY_PATCH/PLATFORM_VERSION are not set here: on the full lineage-19.1 tree
# both are already set (and PLATFORM_SECURITY_PATCH made KATI_READONLY) by
# build/make/core/version_defaults.mk before BoardConfig.mk is even read, so assigning them
# here is a hard config error. They were only settable in the minimal TWRP-only manifest.
# VENDOR_SECURITY_PATCH (the vendor.img side, independent of the system build) is not locked.
VENDOR_SECURITY_PATCH := 2021-11-05

BOARD_AVB_RECOVERY_ADD_HASH_FOOTER_ARGS += \
    --prop com.android.build.boot.os_version:12 \
    --prop com.android.build.boot.security_patch:2019-06-06 \
    --prop com.android.build.system.os_version:12 \
    --prop com.android.build.system.security_patch:2022-08-01 \
    --prop com.android.build.vendor.os_version:12 \
    --prop com.android.build.vendor.security_patch:2021-11-05

# Storage & Encryption
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := false # the metadata partition on the device exists, but it is empty
TW_USE_FSCRYPT_POLICY := 1
TW_PREPARE_DATA_MEDIA_EARLY := true
TW_FORCE_KEYMASTER_VER := true
BOARD_USES_METADATA_PARTITION := true

# SELinux
DEVICE_SEPOLICY_DIR := device/vivo/1907N/sepolicy
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_SEPOLICY_DIR)/public
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_SEPOLICY_DIR)/private
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_SEPOLICY_DIR)/vendor

# Common MediaTek platform sepolicy (device/mediatek/sepolicy_vndr, see local_manifests).
# LineageOS's own copy of this repo only branches from lineage-20 onward; for lineage-19.1
# we pull the StatiXOS "sc" branch instead (see .repo/local_manifests/vivo_1907N.xml).
include device/mediatek/sepolicy_vndr/SEPolicy.mk

# Bring-up aid: relax neverallow enforcement while the device-specific sepolicy above is
# still incomplete. Remove once boot is stable and `mka vendorsepolicy_test`-style checks pass.
SELINUX_IGNORE_NEVERALLOWS := true

# VINTF - manifest.xml/compatibility_matrix.xml are copied verbatim from the stock
# /vendor/etc/vintf/{manifest,compatibility_matrix}.xml (the assembled, already-validated
# manifest vivo ships), not hand-authored - far more reliable than reconstructing HAL
# versions from binary names. Revisit once vendor blobs are extracted (task: proprietary-files)
# to confirm every <hal> entry here actually has a matching service pulled in.
DEVICE_MANIFEST_FILE := device/vivo/1907N/manifest.xml
DEVICE_MATRIX_FILE := device/vivo/1907N/compatibility_matrix.xml

# Modules & Binaries

TARGET_RECOVERY_DEVICE_MODULES += \
    ashmemd_aidl_interface-cpp \
    libashmemd_client \
    ashmemd \
    libtombstoned_client \
    tombstoned \
    liblog \
    libresetprop \
    libminijail \
    libminijail_vendor

RECOVERY_BINARY_SOURCE_FILES += \
    $(PRODUCT_OUT)/system/bin/ashmemd \
    $(PRODUCT_OUT)/system/bin/tombstoned

TW_INCLUDE_RESETPROP := true

TARGET_RECOVERY_DEVICE_MODULES += \
    libresetprop \
    libminijail \
    libminijail_vendor

TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/libresetprop.so
TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/libminijail.so

TARGET_RECOVERY_PIXEL_FORMAT := "BGRA_8888"
# TWRP's own recovery.fstab uses /system_root (its internal bind-mount convention, paired with
# BOARD_ROOT_EXTRA_FOLDERS := system_root below) - real stock boot never mounts a partition there
# (see rootdir/etc/fstab.mt6768, which uses /system directly). ota_from_target_files's block-diff
# code needs a real "/system" fstab entry to generate the OTA package, so the full ROM build must
# get the real fstab instead, not TWRP's.
ifeq ($(TARGET_PRODUCT),twrp_1907N)
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
else
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt6768
endif
BOARD_HAS_NO_SELECT_BUTTON := true
RECOVERY_SDCARD_ON_DATA := true
TW_HAS_MTP := true
TW_INTERNAL_STORAGE_PATH := "/data/media/0"
TW_INTERNAL_STORAGE_MOUNT_POINT := "data"
TW_EXTERNAL_STORAGE_PATH := "/external_sd"
TW_EXTERNAL_STORAGE_MOUNT_POINT := "external_sd"
BOARD_HAS_NO_REAL_SDCARD := true

TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop
TARGET_RECOVERY_INITRC := $(DEVICE_PATH)/recovery/root/init.recovery.mt6768.rc

# Tried pinning this to 31 to match stock's extracted vendor blobs (ro.vndk.version=31 on
# the real stock vendor.img, vs. 32 here) - reverted. Soong hard-crashes
# (cc.go:2037, nil SnapshotInfoProvider) because a pinned non-"current" BOARD_VNDK_VERSION
# requires an actual "vendor_snapshot" + VNDK snapshot package to be present (see
# source.android.com/docs/core/architecture/vndk/snapshot-vendor) - normally generated by
# running `m dist vendor-snapshot` against a real Android 12.0 AOSP checkout, which doesn't
# exist here. Real mismatch, not a practically fixable one without that infrastructure.
BOARD_VNDK_VERSION := current

# Extracted vendor blobs (see vendor/vivo/1907N/extract-files.sh); safe to include even
# before extraction has been run, since the generated file is created empty either way.
-include vendor/vivo/1907N/BoardConfigVendor.mk

# --- Everything below this point is TWRP recovery-only config (TW_*, RECOVERY_*) and is
# --- inert for the full lineage_1907N build target; kept so the twrp_1907N recovery lunch
# --- target keeps working unmodified.

BOARD_ROOT_EXTRA_FOLDERS := system_root

TW_BRIGHTNESS_PATH := /sys/class/leds/lcd-backlight/brightness
TARGET_RECOVERY_LCD_BACKLIGHT_PATH := \"/sys/class/leds/lcd-backlight/brightness\"
TW_CUSTOM_CPU_TEMP_PATH := /sys/devices/virtual/thermal/thermal_zone1/temp
TW_MAX_BRIGHTNESS := 2047
TW_DEFAULT_BRIGHTNESS := 2000
TW_NO_SCREEN_BLANK := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_INPUT_BLACKLIST := "hbtp_vm,vivo_ts_fp,gf-keys,ACCDET"

TW_THEME := portrait_hdpi
DEVICE_SCREEN_WIDTH := 1080
DEVICE_SCREEN_HEIGHT := 2340
TW_STATUS_BAR_STACKING_OFFSET := 70
TW_STATUS_BAR_PADDING_LEFT := 40
TW_STATUS_BAR_PADDING_RIGHT := 40
TW_CLOCK_OFFSET := 100

TARGET_SCREEN_WIDTH := 1080
TARGET_SCREEN_HEIGHT := 2340

TW_USE_MODEL_HARDWARE_ID_FOR_DEVICE_ID := true
TW_USE_TOOLBOX := true
TW_EXTRA_LANGUAGES := false
TW_DEFAULT_LANGUAGE := en
TW_INCLUDE_NTFS_3G := true
TARGET_USES_MKE2FS := true

TARGET_USE_CONFIGFS := true
TW_USB_CONFIGFS_STRINGS := true
TW_EXCLUDE_LUN_0 := true
TW_EXCLUDE_DEFAULT_USB_INIT := false
TARGET_RECOVERY_USB_ID_VENDOR := 0x2D95
TARGET_RECOVERY_USB_ID_PRODUCT := 0x6012

TWRP_INCLUDE_LOGCAT := true
TW_INCLUDE_FASTBOOTD := false
TARGET_USES_LOGD := true
TW_EXCLUDE_TWRPAPP := true
TW_EXCLUDE_APEX := true

TW_DEFAULT_DEVICE_NAME := vivo_V17_Neo
TW_DEVICE_VERSION := vivo 1907 - kavindren
