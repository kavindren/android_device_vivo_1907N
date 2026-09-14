LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE       := fstab.mt6768
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := etc/fstab.mt6768
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := vendor_etc_gnss_agps_profiles_conf2_symlink
LOCAL_MODULE_STEM  := agps_profiles_conf2.xml
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := etc/gnss_agps_profiles_conf2_placeholder
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)/gnss
LOCAL_POST_INSTALL_CMD := ln -sf /data/vendor/gps/agps_profiles_conf2.xml $(TARGET_OUT_VENDOR_ETC)/gnss/agps_profiles_conf2.xml
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.usbfix.rc
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := etc/init.usbfix.rc
LOCAL_MODULE_PATH  := $(TARGET_OUT_ETC)/init
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.no-serial-console.rc
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := etc/init.no-serial-console.rc
LOCAL_MODULE_PATH  := $(TARGET_OUT_ETC)/init
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.udfps-hbm.rc
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := etc/init.udfps-hbm.rc
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)/init
include $(BUILD_PREBUILT)

# /vendor/etc/init so it runs as vendor_init (permitted to set vendor_vivo_defend_prop).
include $(CLEAR_VARS)
LOCAL_MODULE       := init.vivo-defend.rc
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := etc/init.vivo-defend.rc
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)/init
include $(BUILD_PREBUILT)
