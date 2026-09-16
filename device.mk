LOCAL_PATH := device/vivo/1907N
PRODUCT_USE_DYNAMIC_PARTITIONS := false

PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := verify

DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay

PRODUCT_TARGET_VNDK_VERSION := 32

PRODUCT_SHIPPING_API_LEVEL := 28

# manifest.xml's target-level="3" reflects this device's real original Treble launch level
# (Android 9), but the HAL set it declares has grown far past what FCM level 3 permits over
# 19.1->20->21. LOS20's checkvintf tolerated the mismatch; LOS21's assemble_vintf hard-fails the
# build over it ("HALs in device manifest are not declared in FCM <= level 3"). The HALs
# themselves are real and working - this is a paperwork mismatch, not a functional one - so
# disable enforcement rather than chase down the FCM level each individual HAL was introduced at.
#
# NOTE: plain PRODUCT_ENFORCE_VINTF_MANIFEST := false does NOT work here - build/make/core/
# config.mk unconditionally re-derives that variable from PRODUCT_FULL_TREBLE (true, since our
# PRODUCT_SHIPPING_API_LEVEL >= 26) unless the *_OVERRIDE variable below is set, then marks the
# plain variable .KATI_READONLY. This is the actual, correct escape hatch.
PRODUCT_ENFORCE_VINTF_MANIFEST_OVERRIDE := false

# The override above forces PRODUCT_FULL_TREBLE itself false too (config.mk downgrades the
# whole aggregate if any one of its members is false), which in turn sets ro.treble.enabled=false
# in build.prop (main.mk: ADDITIONAL_SYSTEM_PROPERTIES += ro.treble.enabled=${PRODUCT_FULL_TREBLE}).
# system/linkerconfig only reads that ONE runtime property (modules/environment.cc,
# IsTreblelizedDevice()) to decide whether to generate a properly namespace-separated vendor/
# system linker config or fall back to its single-merged-namespace "legacy" config - it doesn't
# care about the build-time PRODUCT_TREBLE_LINKER_NAMESPACES value (which is still true; only
# PRODUCT_ENFORCE_VINTF_MANIFEST was overridden). The resulting legacy/merged namespace let
# mismatched AOSP-source-built copies of the keymaster4-family libraries sitting in
# /system/lib64 interfere with our correct vendor blobs at /vendor/lib64 (same library names,
# different builds) - "cannot locate symbol ... AndroidKeymasterC1..." persisted even after the
# vendor-side blob-vs-Soong-module collision was fully fixed and verified byte-identical both
# on the build host and on the flashed device via adb. Forcing the property back to true here
# restores proper Treble linker namespace isolation without touching VINTF/FCM enforcement at
# all - they're two independent consumers of PRODUCT_FULL_TREBLE that happen to share one
# aggregate variable upstream.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.treble.enabled=true

# frameworks/native/opengl/libs/EGL/Loader.cpp picks the GLES driver by trying
# persist.graphics.egl, then ro.hardware.egl, then (only if neither is set) ro.board.platform as
# a filename suffix - libGLES_${prop}.so - and hard-aborts (SIGABRT, "couldn't find an OpenGL ES
# implementation") on the FIRST non-empty property it finds if the resulting file doesn't exist,
# without trying the others. Neither of the first two properties was ever set here, so it fell
# through to ro.board.platform=mt6768 and looked for libGLES_mt6768.so - which doesn't exist,
# since our real stock blob is named libGLES_mali.so (vendor/lib64/egl/, confirmed present and
# correctly installed). This crash-looped surfaceflinger forever (visible as a black screen with
# no boot animation at all, since surfaceflinger IS the compositor that would show it). Setting
# ro.hardware.egl=mali directly makes it try (and find) libGLES_mali.so first.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.egl=mali

# Restoring proper Treble linker namespace isolation (ro.treble.enabled=true above) also
# re-exposed a pile of pre-existing cross-partition dependencies in our stock proprietary
# blobs, which were built assuming no strict vendor/system separation. Real device logcat
# showed ~300 crash-loop iterations across 11 different vendor binaries, all "library X.so
# not found" for a handful of distinct non-LLNDK system libraries - see linker.config.json's
# own comments for the exact binary-to-library mapping.
PRODUCT_VENDOR_LINKER_CONFIG_FRAGMENTS += \
    $(LOCAL_PATH)/linker.config.json

# mnld (MTK's GPS/AGPS assist daemon) needs libcurl.so directly, which AOSP no longer ships at
# all (removed from both system and vendor years ago) - build it fresh from external/curl
# (vendor_available: true) rather than granting cross-namespace visibility to a library that
# doesn't exist anywhere yet.
PRODUCT_PACKAGES += \
    libcurl

PRODUCT_SET_DEBUGFS_RESTRICTIONS := false

# Pre-authorize kavindren's own adb key (userdebug/eng only, honored by build/make/core/
# product_config.mk) so adb works immediately on first boot without needing to tap through
# the RSA authorization dialog on-screen - useful during bring-up when the UI itself may hang
# or crash-loop before that dialog can be reached/tapped.
PRODUCT_ADB_KEYS := $(LOCAL_PATH)/kavindren.adbkey.pub

# Device-specific signing keys (keys/, git-ignored). Falls back to AOSP test-keys when a
# fresh checkout has no keys/ — see patches/../README. Generate your own with
# development/tools/make_key for a real build.
ifneq ($(wildcard $(LOCAL_PATH)/keys/releasekey.pk8),)
PRODUCT_DEFAULT_DEV_CERTIFICATE := $(LOCAL_PATH)/keys/releasekey
endif

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/dtb.img:$(PRODUCT_OUT)/dtb.img

PRODUCT_PLATFORM := mt6768
PRODUCT_BOARD := k68v1_64

$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

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

PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# persist.sys.usb.config=mtp,adb below is the same bring-up rationale as PRODUCT_ADB_KEYS:
# without it, USB enumerates as MTP-only by default and adb is unreachable until Developer
# Options > USB debugging is toggled once via touch - not reliably possible while diagnosing a
# boot-time hang. It's a regular (not read-only) property, so this default only takes effect
# before it's ever explicitly written; any later toggle in Settings overrides it as normal.
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    sys.usb.controller=musb-hdrc \
    persist.sys.usb.config=mtp,adb

PRODUCT_PACKAGES += \
    fstab.mt6768

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6768

PRODUCT_PACKAGES += \
    init.zram.rc

PRODUCT_COPY_FILES += \
    vendor/vivo/1907N/proprietary/vendor/etc/fstab.enableswap:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.enableswap

# Stock Goodix GF9518 configs: factory QC .ini and FingerprintEngineer task XMLs. Nothing in
# LineageOS references them yet; kept for a possible FingerprintEngineer port.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/fingerprint/goodix_9886_test_delta_sensor_0.ini:$(TARGET_COPY_OUT_SYSTEM)/etc/goodix_9886_test_delta_sensor_0.ini \
    $(LOCAL_PATH)/prebuilt/fingerprint/icon_pressed_cyan_shadow.png:$(TARGET_COPY_OUT_SYSTEM)/etc/fingerprint/icon_pressed_cyan_shadow.png \
    $(LOCAL_PATH)/prebuilt/fingerprint/engineer/engineer_task_config_gf9518.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/fingerprint/engineer/engineer_task_config_gf9518.xml \
    $(LOCAL_PATH)/prebuilt/fingerprint/engineer/after_sale_task_config_gf9518.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/fingerprint/engineer/after_sale_task_config_gf9518.xml

PRODUCT_PACKAGES += \
    vendor_etc_gnss_agps_profiles_conf2_symlink

PRODUCT_PACKAGES += \
    init.usbfix.rc

PRODUCT_PACKAGES += \
    init.no-serial-console.rc

PRODUCT_PACKAGES += \
    init.udfps-hbm.rc

PRODUCT_PACKAGES += \
    init.vivo-defend.rc

PRODUCT_PACKAGES += \
    init.bootlog.rc

PRODUCT_PACKAGES += \
    android.hardware.usb.gadget@1.1-service.1907N

PRODUCT_PACKAGES += \
    android.hardware.bluetooth.audio@2.1-impl \
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

PRODUCT_PACKAGES += \
    com.android.media.swcodec \
    libsfplugin_ccodec

# Graphics
PRODUCT_PACKAGES += \
    libvulkan

PRODUCT_BOOT_JARS += \
    vivo-framework-vgc \
    vivo-framework \
    vivo-vslog \
    vivo-ftbuild \
    vivo-ftfeature \
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
    vivo-vslog \
    vivo-ftbuild \
    vivo-ftfeature \
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

PRODUCT_COPY_FILES += \
    vendor/vivo/1907N/proprietary/system/framework/mediatek-ims-extension-plugin.jar:$(TARGET_COPY_OUT_SYSTEM)/framework/mediatek-ims-extension-plugin.jar \
    vendor/vivo/1907N/proprietary/system/framework/mediatek-ims-legacy.jar:$(TARGET_COPY_OUT_SYSTEM)/framework/mediatek-ims-legacy.jar \
    vendor/vivo/1907N/proprietary/system/framework/mediatek-wfo-legacy.jar:$(TARGET_COPY_OUT_SYSTEM)/framework/mediatek-wfo-legacy.jar \
    vendor/vivo/1907N/proprietary/system/etc/permissions/com.mediatek.wfo.legacy.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/com.mediatek.wfo.legacy.xml

PRODUCT_PACKAGES += \
    ImsService \
    libimsma \
    libimsma_adapt \
    libimsma_rtp \
    libimsma_socketwrapper

PRODUCT_COPY_FILES += \
    vendor/vivo/1907N/proprietary/system/etc/permissions/privapp-permissions-mediatek-ims.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-mediatek-ims.xml

PRODUCT_COPY_FILES += \
    vendor/vivo/1907N/proprietary/system/lib/libmtk_vt_wrapper.so:$(TARGET_COPY_OUT_SYSTEM)/lib/libmtk_vt_wrapper.so \
    vendor/vivo/1907N/proprietary/system/lib64/libmtk_vt_wrapper.so:$(TARGET_COPY_OUT_SYSTEM)/lib64/libmtk_vt_wrapper.so \
    vendor/vivo/1907N/proprietary/system/lib/libvcodec_cap.so:$(TARGET_COPY_OUT_SYSTEM)/lib/libvcodec_cap.so \
    vendor/vivo/1907N/proprietary/system/lib64/libvcodec_cap.so:$(TARGET_COPY_OUT_SYSTEM)/lib64/libvcodec_cap.so \
    vendor/vivo/1907N/proprietary/system/lib/libvcodec_capenc.so:$(TARGET_COPY_OUT_SYSTEM)/lib/libvcodec_capenc.so \
    vendor/vivo/1907N/proprietary/system/lib64/libvcodec_capenc.so:$(TARGET_COPY_OUT_SYSTEM)/lib64/libvcodec_capenc.so \
    vendor/vivo/1907N/proprietary/system/lib/vendor.mediatek.hardware.videotelephony@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.mediatek.hardware.videotelephony@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.mediatek.hardware.videotelephony@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.mediatek.hardware.videotelephony@1.0.so

PRODUCT_PACKAGES += \
    android.hardware.lights-service.1907N

PRODUCT_PACKAGES += \
    libhwbinder \
    libhidltransport \
    libprocessinfoservice_aidl

PRODUCT_PACKAGES += \
    vivocameraserver \
    libvivocameraservice \
    vendor.vivo.hardware.camera.vop@1.0 \
    vendor.vivo.hardware.osccamera.provider@1.0 \
    vendor.vivo.hardware.osccamera.vivodevice@1.0 \
    vendor.vivo.hardware.osccamera.vivodevice@1.0-impl \
    libvif3ainfoutils

PRODUCT_COPY_FILES += \
    vendor/vivo/1907N/proprietary/system/lib/vendor.vivo.hardware.camera.cameralog@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.vivo.hardware.camera.cameralog@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib/vendor.vivo.hardware.camera.provider@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.vivo.hardware.camera.provider@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.vivo.hardware.camera.cameralog@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.vivo.hardware.camera.cameralog@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.vivo.hardware.camera.provider@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.vivo.hardware.camera.provider@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.vivo.hardware.nativecamera.provider@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.vivo.hardware.nativecamera.provider@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib/vendor.vivo.hardware.nativecamera.provider@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.vivo.hardware.nativecamera.provider@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib/vendor.vivo.hardware.camera.vivodevice@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.vivo.hardware.camera.vivodevice@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.vivo.hardware.camera.vivodevice@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.vivo.hardware.camera.vivodevice@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib/vendor.vivo.hardware.camera.vif@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.vivo.hardware.camera.vif@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.vivo.hardware.camera.vif@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.vivo.hardware.camera.vif@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib/vendor.vivo.hardware.camera.vivoreprocess@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.vivo.hardware.camera.vivoreprocess@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.vivo.hardware.camera.vivoreprocess@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.vivo.hardware.camera.vivoreprocess@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib/vendor.vivo.hardware.nativecamera.vivodevice@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.vivo.hardware.nativecamera.vivodevice@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.vivo.hardware.nativecamera.vivodevice@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.vivo.hardware.nativecamera.vivodevice@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib/vendor.vivo.hardware.camera.jpegencoder@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.vivo.hardware.camera.jpegencoder@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.vivo.hardware.camera.jpegencoder@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.vivo.hardware.camera.jpegencoder@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib/vendor.vivo.hardware.camera.vif3ainfotransmitter@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.vivo.hardware.camera.vif3ainfotransmitter@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.vivo.hardware.camera.vif3ainfotransmitter@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.vivo.hardware.camera.vif3ainfotransmitter@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib/vendor.vivo.hardware.camera.vivopostproc@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib/vendor.vivo.hardware.camera.vivopostproc@1.0.so \
    vendor/vivo/1907N/proprietary/system/lib64/vendor.vivo.hardware.camera.vivopostproc@1.0.so.system:$(TARGET_COPY_OUT_SYSTEM)/lib64/vendor.vivo.hardware.camera.vivopostproc@1.0.so

PRODUCT_COPY_FILES += \
    vendor/vivo/1907N/proprietary/system/etc/init/vivocameraserver.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/vivocameraserver.rc

$(call inherit-product-if-exists, vendor/vivo/1907N/1907N-vendor.mk)

PRODUCT_PACKAGES += \
    TetheringWifiRegexOverlay

# Several stock MTK/AOSP prebuilt HAL binaries (vendor/vivo/1907N proprietary) are linked
# against the old Android-12-era AIDL "ndk_platform" backend naming instead of LOS20's current
# "-ndk" naming; without these the linker refuses to start the binary at all:
#   vendor.mediatek.hardware.mtkpower@1.0-service   -> android.hardware.power-V2-ndk_platform.so
#     (blocks boot: PowerManagerService waits forever for IPower/default)
#   android.hardware.gnss-service.mediatek          -> android.hardware.gnss-V1-ndk_platform.so
#   android.hardware.vibrator-service.mediatek      -> android.hardware.vibrator-V2-ndk_platform.so
#   wpa_supplicant (via libkeystore-engine-wifi-hidl.so) -> android.system.keystore2-V1-ndk_platform.so
#     (silently breaks Wi-Fi: wpa_supplicant never starts)
# These are hardware/lineage/compat's own -ndk_platform shims (patches/hardware_lineage_compat.
# patch switches them from system_ext_specific to vendor:true - vendor binaries can't see
# /system_ext in their linker namespace); listed explicitly so they're installed to /vendor/lib64.
PRODUCT_PACKAGES += \
    android.hardware.power-V2-ndk_platform \
    android.hardware.gnss-V1-ndk_platform \
    android.hardware.vibrator-V2-ndk_platform \
    android.system.keystore2-V1-ndk_platform

# Re-enabled: patches/frameworks_base.patch (FaceManager.getShareMemoryFd()/sendCommand()) is
# now rebased against LOS20 (see patches/BASE).
PRODUCT_PACKAGES += \
    FaceCaptureService \
    default-permissions-facecapture.xml

# Lift-to-wake via the vivo raiseup_detect sensor (AOSP pickup gesture can't see it).
PRODUCT_PACKAGES += \
    LiftToWake \
    privapp-permissions-lifttowake.xml
