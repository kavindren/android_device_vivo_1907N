LOCAL_PATH := device/vivo/1907N
PRODUCT_USE_DYNAMIC_PARTITIONS := false

# VNDK
PRODUCT_TARGET_VNDK_VERSION := 31

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
    plat_keystore2_key_contexts
