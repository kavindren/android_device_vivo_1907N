# LineageOS 19.1 device tree — vivo V17 Neo (1907N / PD1913F_EX)

| | |
| :--- | :--- |
| SoC | MediaTek MT6768 (Helio P65) |
| CPU | 2×2.0 GHz Cortex-A75 + 6×1.7 GHz Cortex-A55 |
| GPU | Mali-G52 MC2 |
| RAM | 6 GB |
| Shipped Android | 9 → 12 (Funtouch `SP1A.210812.003`) |
| LineageOS base | 19.1 (Android 12.1 / API 32) |

## Feature status

| Works | Broken / partial |
| :--- | :--- |
| Boot, RIL (calls/SMS/data), Wi-Fi, BT, GPS, sensors, camera, audio, USB (ADB/MTP), fingerprint (UDFPS), face unlock, FBEv1 decrypt, offline charging | **VoLTE / VoWiFi / IMS** — AP side fully wired but needs an MTK-telephony framework port (`MtkRIL`/`MtkQualifiedNetworksService`); not fixable at device-tree level on A12. IMS toggles appear but never register. |

## Building

Needs a LineageOS 19.1 checkout on Arch or Ubuntu.

### 1. Manifest + sources

```bash
mkdir lineage-19.1 && cd lineage-19.1
repo init -u https://github.com/LineageOS/android.git -b lineage-19.1 --git-lfs
mkdir -p .repo/local_manifests
curl -o .repo/local_manifests/1907N.xml \
  https://raw.githubusercontent.com/kavindren/android_device_vivo_1907N/lineage-19.1/1907N.xml
repo sync -c -j$(nproc)
```

`vendor/vivo/1907N` uses Git LFS for `VivoCamera.apk` — `git lfs install` once beforehand
(the `--git-lfs` on `repo init` covers it).

### 2. Out-of-tree patches

UDFPS HBM, Face Unlock, dual-Wi-Fi SoftAP, tethering and USB gadget need patches to platform
repos:

```bash
device/vivo/1907N/patches/apply-patches.sh
```

See `patches/README.md`.

### 3. Signing keys

The tree builds with AOSP test-keys out of the box. For a real build, generate your own:

```bash
mkdir device/vivo/1907N/keys && cd device/vivo/1907N/keys
for k in releasekey platform shared media networkstack testkey; do
  ../../../../development/tools/make_key "$k" '/CN=vivo-1907N/'; done
openssl genrsa -out avb_recovery.pem 4096
```

`keys/` is git-ignored. `device.mk` / `BoardConfig.mk` auto-detect it.

### 4. Build

```bash
. build/envsetup.sh
lunch lineage_1907N-userdebug
mka bacon            # or: mka bootimage systemimage vendorimage
```

## Flashing

The bootloader must be unlocked. On vivo this is non-trivial — three known routes:

1. Roll back to Android 10 firmware where `fastboot flashing unlock` still works —
   <https://4pda.to/forum/index.php?showtopic=963689&st=440#entry100106035>
2. vivo-specific patched fastboot —
   <https://4pda.to/forum/index.php?showtopic=1047450#entry114868014>
3. Testpoint + mtkclient —
   <https://4pda.to/forum/index.php?showtopic=1047450&st=1100#entry139919639>

Route 3 is the most reliable. `MT6768_Android_scatter.txt` for SP Flash Tool is in the repo.

Then:

```bash
fastboot flash boot   out/target/product/1907N/boot.img
fastboot flash system out/target/product/1907N/system.img
fastboot flash vendor  out/target/product/1907N/vendor.img
fastboot -w
fastboot reboot
```

## Credits

- LineageOS team
- 4PDA community — bootloader unlock research and testing
  (<https://4pda.to/forum/index.php?showtopic=1047450>)
