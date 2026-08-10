LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE       := fstab.mt6768
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := etc/fstab.mt6768
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)
include $(BUILD_PREBUILT)

# Stock ships this path as a symlink to /data/vendor/gps/agps_profiles_conf2.xml, populated at
# runtime by the AGPS/GNSS services. vendor.img only has a broken/empty copy, so install a
# placeholder and replace it with the real symlink post-install, same idiom system/core/rootdir
# uses for its own partition-compat symlinks.
include $(CLEAR_VARS)
LOCAL_MODULE       := vendor_etc_gnss_agps_profiles_conf2_symlink
LOCAL_MODULE_STEM  := agps_profiles_conf2.xml
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := etc/gnss_agps_profiles_conf2_placeholder
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)/gnss
LOCAL_POST_INSTALL_CMD := ln -sf /data/vendor/gps/agps_profiles_conf2.xml $(TARGET_OUT_VENDOR_ETC)/gnss/agps_profiles_conf2.xml
include $(BUILD_PREBUILT)

# USB fix: overrides the platform's disabled/apex-only "adbd" service with one that execs the
# flattened APEX binary directly, bypassing apexd activation entirely (see rootdir/etc/init.usbfix.rc).
# MUST install under $(TARGET_OUT)/etc/init (system side), NOT vendor - init's "override" service
# check (service_parser.cpp) rejects an override whose subcontext differs from the original's, and
# only /vendor and /odm get parsed under the separate vendor Subcontext (system/core/init/
# subcontext.cpp: InitializeSubcontext() only lists "/vendor","/odm"). The original "adbd" service
# is defined in system/core/rootdir/init.usb.rc, which lives on the system side - a vendor-side
# override here would silently fail the treble-boundary check instead of taking effect.
include $(CLEAR_VARS)
LOCAL_MODULE       := init.usbfix.rc
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := etc/init.usbfix.rc
LOCAL_MODULE_PATH  := $(TARGET_OUT_ETC)/init
include $(BUILD_PREBUILT)
