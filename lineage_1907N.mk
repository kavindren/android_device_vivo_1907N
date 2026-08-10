# Release name
PRODUCT_RELEASE_NAME := 1907N

# Inherit some common Lineage stuff.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit device configuration
$(call inherit-product, device/vivo/1907N/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_1907N
PRODUCT_DEVICE := 1907N
PRODUCT_MANUFACTURER := vivo
PRODUCT_BRAND := vivo
PRODUCT_MODEL := vivo 1907

# Reuse the stock fingerprint for DRM/attestation-adjacent compatibility
BUILD_FINGERPRINT := vivo/1907N/1907N:12/SP1A.210812.003/compiler10211509:user/release-keys
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="full_k68v1_64-user 12 SP1A.210812.003 compiler10211509 release-keys"
