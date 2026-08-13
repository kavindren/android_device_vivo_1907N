LOCAL_PATH := device/vivo/1907N
PRODUCT_USE_DYNAMIC_PARTITIONS := false

# Navigation bar fix (see overlay/frameworks/base/core/res/res/values/config.xml) - this
# device has no hardware nav keys, so config_showNavigationBar must be true or Settings
# hides the entire system-navigation switcher (3-button/2-button/gestures), not just the
# gestures option.
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay

# VNDK
# lineage-19.1 tracks Android 12.1/12L (API 32), not plain Android 12 (API 31, which is what
# stock's extracted vendor blobs actually are). Pinning this to 31 to match was tried and
# reverted - see BoardConfig.mk's BOARD_VNDK_VERSION comment for why (needs real
# vendor_snapshot infrastructure we don't have). Stays 32 so the tree builds at all; the
# resulting VNDK mismatch against stock's closed vendor blobs is real and unresolved.
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
# it here so adb is available from the very first boot, before /data/property has any
# persisted override.
#
# ADB-only for now, not "mtp,adb" - keeping the first real test of the no-custom-HAL approach
# below to the simplest possible case. Now that the custom HAL is out of the build entirely,
# MTP goes through vivo's own init.mt6768.usb.rc handlers directly (which correctly use
# functions/ffs.mtp, unlike our old HAL's buggy vendored copy) - worth trying again once adb
# alone is confirmed working.
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=adb

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

# USB fix, part 2 - attempts #1 through #4 (see usb/, kept in the tree but no longer built into
# any product package) all tried to provide a custom IUsbGadget HAL, on the premise that
# frameworks/base's UsbDeviceManager.IUsbGadget.getService(true) hangs forever at system_server
# construction time if nothing implements the interface. Checked directly against the real stock
# vendor.img (mounted read-write at ~/android_mount) instead of assuming: stock's own
# vendor/etc/vintf/manifest has zero android.hardware.usb.gadget entries, and stock Funtouch
# obviously still boots - so that premise doesn't hold when the interface isn't declared in any
# manifest at all (HIDL's getService(true) only actually blocks/retries for a lazy service that
# IS declared but not yet registered, not for one nobody claims to provide - it should throw
# NoSuchElementException promptly and fall back to UsbHandlerLegacy instead).
#
# UsbHandlerLegacy's actual function-setting path (UsbDeviceManager.java, UsbHandlerLegacy.
# setUsbConfig()) turns out to just do setSystemProperty("sys.usb.config", config) - it does NOT
# depend on the old /sys/class/android_usb/android0 sysfs attributes being writable (those are
# only read from, for status). That's exactly the property vendor/etc/init/hw/init.mt6768.usb.rc's
# entire state machine reacts to and already handles correctly end to end (same mechanism TWRP's
# own working ADB goes through). So: no custom HAL needed at all - just let UsbDeviceManager fall
# back to Legacy and hand off to vivo's own already-proven init.mt6768.usb.rc.
#
# If this turns out to be wrong and getService(true) really does hang here, the fix is trivial:
# reinstate `PRODUCT_PACKAGES += android.hardware.usb.gadget@1.1-service.1907N` (source untouched
# in usb/) and reflash - recoverable via TWRP either way, this doesn't touch anything TWRP needs.

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

# Prebuilt vivo/MTK bootclasspath jars (see vendor/vivo/1907N/proprietary/system/framework/
# Android.bp - dex_import modules, extracted straight from stock's /system/framework since
# these are proprietary and never built from source anywhere in this tree). Needed for
# IMS/VoLTE: mediatek-ims-base.jar and mediatek-ims-common.jar are what ImsService.apk (see
# below) actually links against, but stock's own bootclasspath.pb records ALL of these as
# one ordered list - the MTK/vivo jars appear to reference each other's classes directly
# (mediatek-framework depends on mediatek-common, vivo-telephony-common on vivo-framework,
# etc.), so this is the full set stock ships, in the exact order recorded in stock's
# /system/etc/classpaths/bootclasspath.pb, not just the two IMS ones.
PRODUCT_BOOT_JARS += \
    vivo-framework-vgc \
    vivo-framework \
    vivo-media \
    framework-adapter \
    soc-framework \
    vivo-telephony-common \
    vivo-vgcclient \
    mediatek-telephony-base \
    mediatek-telephony-common \
    mediatek-common \
    mediatek-framework \
    mediatek-ims-common \
    mediatek-ims-base \
    mediatek-telecom-common

PRODUCT_PACKAGES += \
    vivo-framework-vgc \
    vivo-framework \
    vivo-media \
    framework-adapter \
    soc-framework \
    vivo-telephony-common \
    vivo-vgcclient \
    mediatek-telephony-base \
    mediatek-telephony-common \
    mediatek-common \
    mediatek-framework \
    mediatek-ims-common \
    mediatek-ims-base \
    mediatek-telecom-common

# IMS: the actual ImsService priv-app (see vendor/vivo/1907N/proprietary/system/priv-app/
# ImsService/) that Settings/ImsManager bind to - without it there's no IMS provider
# registered at all, which is why VoLTE/VoWiFi/ViLTE toggles don't show up in Settings to
# begin with, not just fail to connect. libimsma* are its native support libraries.
PRODUCT_PACKAGES += \
    ImsService \
    libimsma \
    libimsma_adapt \
    libimsma_rtp \
    libimsma_socketwrapper

PRODUCT_COPY_FILES += \
    vendor/vivo/1907N/proprietary/system/etc/permissions/privapp-permissions-mediatek-ims.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-mediatek-ims.xml

# Inherit the extracted vendor blobs once vendor/vivo/1907N/1907N-vendor.mk exists
# (generated by vendor/vivo/1907N/extract-files.sh - see that tree's README)
$(call inherit-product-if-exists, vendor/vivo/1907N/1907N-vendor.mk)
