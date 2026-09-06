LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE), 1907N)
include $(call all-subdir-makefiles, $(LOCAL_PATH))
endif

