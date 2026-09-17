# Get the directory for this file, and use that instead of a fixed path.
local_dir := $(dir $(lastword $(MAKEFILE_LIST)))

# Device-specific override on top of the AOSP/LineageOS "ap2a" release config: this device
# is a legacy (non-GKI) MTK board that genuinely needs VNDK (BOARD_VNDK_VERSION := current,
# real vendor blobs consuming HIDL/AIDL interface libs with a stable ABI boundary). AOSP's
# own build/release/build_config/ap2a.scl sets RELEASE_DEPRECATE_VNDK := True (meant for
# modern GKI devices that no longer need a VNDK split at all) - on this device that silently
# starves KEEP_VNDK (build/make/core/envsetup.mk) to false, which cascades into ro.vndk.version
# never being set, which in turn means system/linkerconfig's sphal namespace (contents/
# namespace/sphal.cc, IsVendorVndkVersionDefined()) never links to the vndk namespace at all -
# confirmed via a real device: /vendor/lib64/egl/libGLES_mali.so (a VNDK-SP/support_system_process
# HAL) couldn't see android.hardware.graphics.mapper@4.0.so from the sphal namespace, hard-aborting
# surfaceflinger/gpuservice ("couldn't find an OpenGL ES implementation") in an infinite crash
# loop. This is very likely the same underlying gap behind several other VNDK cross-namespace
# issues chased down earlier in this port (empty vndkcorevariant.libraries.txt, etc.) - see
# device git history.
$(call declare-release-config, ap2a, $(local_dir)build_config/ap2a.scl)

local_dir :=
