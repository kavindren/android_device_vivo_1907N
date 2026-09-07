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

PRODUCT_PACKAGES += \
    VivoCamera

PRODUCT_COPY_FILES += \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libalgo_rithm_jni.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libalgo_rithm_jni.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libalgo_youtu_jni.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libalgo_youtu_jni.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libalLDC.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libalLDC.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libarcsoft_noteengine.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libarcsoft_noteengine.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libarcsoft_panorama_burstcapture.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libarcsoft_panorama_burstcapture.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libarcsoft_wideselfie.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libarcsoft_wideselfie.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libBaiduSpeechSDK.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libBaiduSpeechSDK.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libbdEASRAndroid_e2e.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libbdEASRAndroid_e2e.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libbd_easr_s1_merge_english.dat.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libbd_easr_s1_merge_english.dat.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libbitmaps.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libbitmaps.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libCameraShowYUV.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libCameraShowYUV.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libComposition.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libComposition.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libc++_shared.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libc++_shared.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libdoc_detect.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libdoc_detect.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libFaceDistortion.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libFaceDistortion.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libformat_convert.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libformat_convert.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libGestureDetectJni.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libGestureDetectJni.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libgifimage.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libgifimage.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libgnustl_shared.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libgnustl_shared.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libHistogram.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libHistogram.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libijkffmpeg.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libijkffmpeg.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libimage_filter_common.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libimage_filter_common.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libimage_filter_gpu.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libimage_filter_gpu.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libimagepipeline.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libimagepipeline.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libjni_camgraphic.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libjni_camgraphic.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libjni_jpegutil.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libjni_jpegutil.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libjni_scaleyuv.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libjni_scaleyuv.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libjni_yuvutil.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libjni_yuvutil.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/liblicense_baidu_duersdk_camera.data.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/liblicense_baidu_duersdk_camera.data.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libmegface_portrait.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libmegface_portrait.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libMegviiHum-jni-1.0.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libMegviiHum-jni-1.0.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libMegviiHum.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libMegviiHum.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libmemchunk.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libmemchunk.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libmp4v2.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libmp4v2.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libmpbase.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libmpbase.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libneuropilot_jni.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libneuropilot_jni.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libnnpack.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libnnpack.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libnti_cv.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libnti_cv.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libnti_picopo.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libnti_picopo.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libNvEffectSdkCore.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libNvEffectSdkCore.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libNvStreamingSdkCore.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libNvStreamingSdkCore.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libParticleSystem.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libParticleSystem.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libpitu_tools.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libpitu_tools.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libPPTProcess.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libPPTProcess.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libringlightdecoder.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libringlightdecoder.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libSceneChangedNative.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libSceneChangedNative.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libscene-detect.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libscene-detect.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libsdk_skeletal_animation.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libsdk_skeletal_animation.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libsegmentern.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libsegmentern.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libsegmentero.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libsegmentero.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libsnpe-android.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libsnpe-android.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libSNPE.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libSNPE.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libsoft_decoder.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libsoft_decoder.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libSThandDtNative.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libSThandDtNative.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libstmobile_hand.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libstmobile_hand.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libst_render.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libst_render.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libsymphony-cpu.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libsymphony-cpu.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libsymphonypower.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libsymphonypower.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libThreeDeminsBeauty.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libThreeDeminsBeauty.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libvcap.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libvcap.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libVivo3rdJNI.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libVivo3rdJNI.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libvivoDataDiffDetect.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libvivoDataDiffDetect.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libVivoDocRectifyProc.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libVivoDocRectifyProc.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libvivoFlashTest.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libvivoFlashTest.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libvivoIvw36.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libvivoIvw36.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libVivo_meiyan_resource.dat.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libVivo_meiyan_resource.dat.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libvivosgmain.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libvivosgmain.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libwebpimage.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libwebpimage.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libwebp.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libwebp.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libYTCommon.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libYTCommon.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libYTFaceTrackPro.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libYTFaceTrackPro.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libYTHandDetector.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libYTHandDetector.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libYTIllumination.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libYTIllumination.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libyuv_camera.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libyuv_camera.so \
    vendor/vivo/1907N/proprietary/system/app/VivoCamera/lib/arm/libYUVSpliterJNI.so:$(TARGET_COPY_OUT_SYSTEM)/app/VivoCamera/lib/arm/libYUVSpliterJNI.so

$(call inherit-product-if-exists, vendor/vivo/1907N/1907N-vendor.mk)

PRODUCT_PACKAGES += \
    TetheringWifiRegexOverlay

PRODUCT_PACKAGES += \
    FaceCaptureService \
    default-permissions-facecapture.xml
