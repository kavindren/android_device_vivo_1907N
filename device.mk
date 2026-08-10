LOCAL_PATH := device/vivo/1907N
PRODUCT_USE_DYNAMIC_PARTITIONS := false

# VNDK
# lineage-19.1 tracks Android 12.1/12L (API 32), not plain Android 12 (API 31) - the minimal
# TWRP-only manifest this value was originally set for was pure Android 12; the full tree
# computes BOARD_VNDK_VERSION=current -> 32 and hard-fails if this doesn't match.
PRODUCT_TARGET_VNDK_VERSION := 32

# API
PRODUCT_SHIPPING_API_LEVEL := 31

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/dtb.img:$(PRODUCT_OUT)/dtb.img

PRODUCT_PLATFORM := mt6768
PRODUCT_BOARD := k68v1_64

PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service \
    libresetprop \
    libminijail \
    tombstoned \
    ibtombstoned_client \
    ashmemd \
    ashmemd_aidl_interface-cpp \
    libashmemd_client \
    liblog

PRODUCT_PACKAGES += \
    android.system.keystore2-service \
    plat_keystore2_key_contexts \
    libperfmgr

PRODUCT_PACKAGES += \
    crash_dump \
    crash_dump.recovery

# ---------------------------------------------------------------------------
# Below this point: additions for the full lineage_1907N ROM build. Package
# selection is grounded in what's actually present in the stock vendor.img
# dump (vendor/bin/hw, vendor/etc/init) rather than transplanted wholesale
# from the mt6768-common reference trees, since this vivo/BBK firmware ships
# its own vendor.vivo.hardware.* HIDL stack (fingerprint, face, camera3rd,
# configstore, etc.) instead of the generic AOSP/MTK default HALs those
# trees assume. Vendor blobs themselves (HAL service binaries, firmware,
# vendor.vivo.hardware.*, audio/wifi/media XML configs) are intentionally
# NOT hand-listed here — extract-files.sh (vendor/vivo/1907N) generates
# 1907N-vendor.mk with PRODUCT_PACKAGES/PRODUCT_COPY_FILES for every
# extracted proprietary file automatically. What's listed here is only
# source-built AOSP-side code that has to be requested explicitly.
# ---------------------------------------------------------------------------

PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Stock's own vendor/etc/init/hw/init.mt6768.usb.rc implements a large vivo/MTK-specific USB
# gadget state machine driven entirely by the persistent property persist.sys.usb.config -
# on stock this only gets set to include "adb" once the user manually enables USB debugging
# via Developer Options in Settings. Since first boot never reaches usable UI, that toggle is
# unreachable, and USB never enumerates at all (not even as an unauthorized device) - default
# it to mtp,adb here so adb is available from the very first boot, before /data/property has
# any persisted override.
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp,adb

# vendor/etc/init/hw/init.mt6768.usb.rc sets vendor.usb.controller="musb-hdrc" (its own gadget
# functions are gated behind vendor-only properties like vendor.usb.acm_cnt/ro.vendor.vivo.support
# .cdrom that only vivo's own modem/diag stack sets). Platform's own system/core/rootdir/
# init.usb.configfs.rc - the code path that actually does `write .../UDC ${sys.usb.controller}` to
# bind the gadget - reads the *unprefixed* sys.usb.controller, which nothing in this vendor tree
# ever sets. Without it the UDC write is always empty and the gadget genuinely never binds, so USB
# doesn't enumerate on the host at all (not a property-trigger-gating issue, a literal missing UDC
# bind). Hardcode the same value here so platform's own gadget-binding code path actually works.
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    sys.usb.controller=musb-hdrc

# Main-system fstab (see rootdir/). First-stage init needs its own copy in the root
# ramdisk to know how to mount /vendor and /system before /vendor/etc is available;
# fstab.mt6768 is also installed as a regular vendor/etc/ module (matches stock layout
# and is what recovery-mode fastboot/tools expect to find).
PRODUCT_PACKAGES += \
    fstab.mt6768

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6768

# vendor/etc/gnss/agps_profiles_conf2.xml - stock ships this as a symlink to a runtime-populated
# /data path, not a static file (see rootdir/Android.mk for the LOCAL_POST_INSTALL_CMD that
# actually creates the symlink; this just makes sure the module gets built).
PRODUCT_PACKAGES += \
    vendor_etc_gnss_agps_profiles_conf2_symlink

# USB fix (see rootdir/etc/init.usbfix.rc) - overrides the apex-only "adbd" service.
PRODUCT_PACKAGES += \
    init.usbfix.rc

# Audio - standard AOSP-source effects/HAL passthrough modules, hardware-agnostic
PRODUCT_PACKAGES += \
    audio.r_submix.default \
    audio.usb.default \
    audio.bluetooth.default \
    libaudiopreprocessing \
    libbundlewrapper \
    libdownmix \
    libdynproc \
    libeffectproxy \
    libldnhncr \
    libreverbwrapper \
    libvisualizer

# Media - software Codec2 fallback (AOSP source, hardware-agnostic)
PRODUCT_PACKAGES += \
    com.android.media.swcodec \
    libsfplugin_ccodec

# Graphics
PRODUCT_PACKAGES += \
    libvulkan

# Inherit the extracted vendor blobs once vendor/vivo/1907N/1907N-vendor.mk exists
# (generated by vendor/vivo/1907N/extract-files.sh - see that tree's README)
$(call inherit-product-if-exists, vendor/vivo/1907N/1907N-vendor.mk)
