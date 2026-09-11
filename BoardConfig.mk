DEVICE_PATH := device/vivo/1907N

ALLOW_MISSING_DEPENDENCIES := true

BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_PREBUILT_ELF_FILES := true

BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(DEVICE_PATH)/bluetooth

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
androidboot.selinux=enforcing
BOARD_KERNEL_BASE := 0x40078000

SELINUX_IGNORE_NEVERALLOWS := true
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

BOARD_HAS_LARGE_FILESYSTEM := true
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

BOARD_KERNEL_IMAGE_NAME := Image.gz
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_SOURCE := kernel/vivo/1907N
TARGET_KERNEL_CONFIG := pd1913f_defconfig

# NOTE: BoardConfigKernel.mk's own KERNEL_MAKE_FLAGS (used by the vendor/lineage
# "generated_kernel_includes" Soong genrule, i.e. `make headers_install`) needs a matching
# HOSTCFLAGS="-fuse-ld=lld" fix for the same reason as TARGET_KERNEL_ADDITIONAL_FLAGS below -
# appending it here from device/vivo/1907N/BoardConfig.mk did NOT take effect (not yet
# understood why), so the real fix lives directly in vendor/lineage/config/BoardConfigKernel.mk
# instead, applied as patches/vendor_lineage.patch (run patches/apply-patches.sh after every
# fresh repo sync, same as the other 6 out-of-tree patches).
include vendor/lineage/config/BoardConfigKernel.mk

TARGET_KERNEL_CLANG_VERSION := r450784d
KERNEL_LD := LD=ld.lld
# scripts/Makefile.host's cmd_host-csingle (used for fixdep) doesn't pull in HOSTLDFLAGS at
# all - only host-cmulti/host-cshlib do. The clang toolchain LOS20 bundles ships no bfd `ld`,
# so fixdep's build fails ("Executable ld doesn't exist") unless the linker choice is passed
# via HOSTCFLAGS instead, which cmd_host-csingle does use.
# -integrated-as: the Makefile above unconditionally appends -no-integrated-as when clang is
# used, so clang emits .s text for the ancient bundled aarch64-linux-android-4.9 GNU `as` to
# consume - which chokes on newer clang-14 assembly syntax ("junk at end of line" in
# init/calibrate.c and presumably others). KCFLAGS is appended last by kbuild, so this
# re-enables clang's own integrated assembler instead, sidestepping the old `as` entirely.
TARGET_KERNEL_ADDITIONAL_FLAGS := KCFLAGS="-fcolor-diagnostics -Wno-unused-function -Wno-unused-variable -march=armv8.2-a -mtune=cortex-a55 -integrated-as" LOCALVERSION=-kavindren HOSTCFLAGS="-fuse-ld=lld"

BOARD_CUSTOM_DTBIMG_MK := $(DEVICE_PATH)/dtbimg.mk

TARGET_COPY_OUT_VENDOR := vendor

BOARD_AVB_ENABLE := true
# Custom recovery vbmeta key (keys/, git-ignored). Without it, recovery is signed with the
# AVB test key like the rest of vbmeta — fine for an unlocked bootloader.
ifneq ($(wildcard $(DEVICE_PATH)/keys/avb_recovery.pem),)
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_KEY_PATH := $(DEVICE_PATH)/keys/avb_recovery.pem
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
endif
VENDOR_SECURITY_PATCH := 2021-11-05

BOARD_AVB_RECOVERY_ADD_HASH_FOOTER_ARGS += \
    --prop com.android.build.boot.os_version:12 \
    --prop com.android.build.boot.security_patch:2019-06-06 \
    --prop com.android.build.system.os_version:12 \
    --prop com.android.build.system.security_patch:2022-08-01 \
    --prop com.android.build.vendor.os_version:12 \
    --prop com.android.build.vendor.security_patch:2021-11-05

# Storage & Encryption
BOARD_USES_METADATA_PARTITION := true

# SELinux
DEVICE_SEPOLICY_DIR := device/vivo/1907N/sepolicy
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_SEPOLICY_DIR)/public
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_SEPOLICY_DIR)/private
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_SEPOLICY_DIR)/vendor

include device/mediatek/sepolicy_vndr/SEPolicy.mk

DEVICE_MANIFEST_FILE := device/vivo/1907N/manifest.xml
DEVICE_MATRIX_FILE := device/vivo/1907N/compatibility_matrix.xml

# Recovery
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

TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888
# Dedicated recovery fstab (not the vendor first-stage one) — the latter's first_stage_mount /
# check / errors=panic flags and ~30 emmc pseudo-partitions stalled recovery startup by minutes.
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TARGET_RECOVERY_LCD_BACKLIGHT_PATH := \"/sys/class/leds/lcd-backlight/brightness\"
TARGET_SCREEN_WIDTH := 1080
TARGET_SCREEN_HEIGHT := 2340
# 1080x2340 panel. Without this build/make falls back to mdpi (12x22 font, res-mdpi) and the
# recovery UI renders tiny in the top-left. 480dpi -> xxhdpi bucket + 18x32 font.
TARGET_RECOVERY_DENSITY := 480dpi
# MTK panel needs a blank/unblank cycle at UI init or the first frame doesn't scan out.
TARGET_RECOVERY_UI_BLANK_UNBLANK_ON_INIT := true
BOARD_HAS_NO_SELECT_BUTTON := true
RECOVERY_SDCARD_ON_DATA := true
TARGET_USES_MKE2FS := true
TARGET_USE_CONFIGFS := true
TARGET_RECOVERY_USB_ID_VENDOR := 0x2D95
TARGET_RECOVERY_USB_ID_PRODUCT := 0x6012
TARGET_USES_LOGD := true

TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

BOARD_VNDK_VERSION := current

-include vendor/vivo/1907N/BoardConfigVendor.mk

BOARD_ROOT_EXTRA_FOLDERS := system_root
