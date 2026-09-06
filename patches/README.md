# Out-of-tree source patches — vivo 1907N (PD1913F_EX)

A handful of features on this device need changes to LineageOS platform repos that a device
tree can't carry (framework/system Java + init). They're kept here as patches instead of repo
forks so they stay small and easy to forward-port across LineageOS branches.

## Usage

After `repo sync`, run once:

```
device/vivo/1907N/patches/apply-patches.sh
```

Idempotent — already-applied patches are skipped. If a patch fails because the upstream repo
has moved since `BASE` was recorded, the script retries with `git apply --3way` and, failing
that, prints which repo and expected/actual revision so you can rebase the patch by hand.

`BASE` records the LineageOS commit each patch was generated against.

## What each patch changes

| patch | repo | change |
|-------|------|--------|
| `frameworks_base.patch` | `frameworks/base` | **UDFPS local-HBM illumination** — `Vivo1907NUdfpsHbmProvider` (new) + `UdfpsHelper` / `UdfpsController` / `FingerprintSensorPropertiesInternal` / `Fingerprint21` + HIDL clients: drive the panel brightness bump and draw the local illumination dot for this device's under-display sensor (no panel-level local-HBM hardware, so AOSP's `GLOBAL_HBM` drawing path has to be used). **Face Unlock HIDL plumbing** — `FaceManager` / `IFaceService.aidl` / `FaceService` / `ServiceProvider` / `Face10` / `FaceGenerateChallengeClient`: wire this device's `android.hardware.biometrics.face@1.0` vendor HAL through the framework. |
| `packages_apps_Settings.patch` | `packages/apps/Settings` | Face Unlock enrollment UI — education screen, enroll/education animation drawables (`FaceEducationAnimationDrawable` new), preview fragment. Plus `UsbDetailsFunctionsController` (USB functions detail screen). |
| `packages_modules_Connectivity.patch` | `packages/modules/Connectivity` | `Tethering.java` — this device's concurrent STA+AP Wi-Fi creates a fresh dynamically-numbered `wlanN` netdev per SoftAP session and the Tethering process never gets netd's `interfaceAdded` push for it. Register the iface directly on a tether request for an unknown iface instead of waiting for a notification that never arrives. |
| `packages_modules_Wifi.patch` | `packages/modules/Wifi` | `SoftApManager.java` — gate `setApCountryCode()` on the same `isSoftApDynamicCountryCodeSupported()` / `SOFTAP_FEATURE_ACS_OFFLOAD` check `updateCountryCode()` already uses. This device's vendor `libwifi-hal.so` null-derefs in `wifi_set_country_code` when called on a freshly created AP iface. |
| `system_core.patch` | `system/core` | `rootdir/init.usb.configfs.rc` — adapt the configfs USB-gadget bring-up to this device's `musb-hdrc` controller and vivo's own vendor gadget-function naming so the UDC actually binds (otherwise USB never enumerates on the host). |

Rationale in depth lives in the maintainer's private bring-up notes, not in the public tree.
