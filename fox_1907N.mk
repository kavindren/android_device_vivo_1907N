$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

$(call inherit-product, device/vivo/1907N/device.mk)

$(call inherit-product, vendor/twrp/config/common.mk)

PRODUCT_DEVICE := 1907N
PRODUCT_NAME := fox_1907N
PRODUCT_BRAND := vivo
PRODUCT_MODEL := vivo 1907
PRODUCT_MANUFACTURER := vivo
