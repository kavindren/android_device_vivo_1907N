LOCAL_PATH := device/vivo/1907N
PRODUCT_USE_DYNAMIC_PARTITIONS := false

PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := verify

DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay

PRODUCT_TARGET_VNDK_VERSION := 32

PRODUCT_SHIPPING_API_LEVEL := 28

PRODUCT_SET_DEBUGFS_RESTRICTIONS := false

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

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    sys.usb.controller=musb-hdrc

PRODUCT_PACKAGES += \
    fstab.mt6768

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6768

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
    VivoCarrierConfig

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
    vendor.vivo.hardware.osccamera.provider@1.0-service \
    vendor.vivo.hardware.nativecamera.provider@1.0-service \
    vendor.vivo.hardware.camera.cameralog@1.0-service \
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
    vendor/vivo/1907N/proprietary/system/etc/init/vivocameraserver.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/vivocameraserver.rc \
    vendor/vivo/1907N/proprietary/system/etc/init/vendor.vivo.hardware.osccamera.provider@1.0-service.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/vendor.vivo.hardware.osccamera.provider@1.0-service.rc \
    vendor/vivo/1907N/proprietary/system/etc/init/vendor.vivo.hardware.nativecamera.provider@1.0-service.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/vendor.vivo.hardware.nativecamera.provider@1.0-service.rc \
    vendor/vivo/1907N/proprietary/system/etc/init/vendor.vivo.hardware.camera.cameralog@1.0-service.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/vendor.vivo.hardware.camera.cameralog@1.0-service.rc

$(call inherit-product-if-exists, vendor/vivo/1907N/1907N-vendor.mk)

PRODUCT_PACKAGES += \
    TetheringWifiRegexOverlay

# TEMPORARILY DISABLED for LOS20: FaceCaptureService calls FaceManager.getShareMemoryFd()/
# sendCommand() added by our frameworks/base patch (patches/frameworks_base.patch), which
# doesn't apply cleanly against LOS20's newer FaceManager.java yet (see patches/README.md -
# deferred until after basic boot works, per the same plan as the Settings Face Unlock UI
# patch). Re-enable once that patch is rebased.
#PRODUCT_PACKAGES += \
#    FaceCaptureService \
#    default-permissions-facecapture.xml

# Lift-to-wake via the vivo raiseup_detect sensor (AOSP pickup gesture can't see it).
PRODUCT_PACKAGES += \
    LiftToWake \
    privapp-permissions-lifttowake.xml
