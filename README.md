# TWRP Device Tree for Vivo V17 Neo (PD1913F)

![TWRP Version](https://img.shields.io/badge/TWRP-3.7.1-blue.svg)
![Android Version](https://img.shields.io/badge/Android-12%20(S)-green.svg)

## Device Specifications

| Features| Specifications |
| :--- | :--- |
| SoC | MediaTek MT6768 Helio P65 |
| CPU | 2x 2.0 GHz Cortex-A75 & 6x 1.7 GHz Cortex-A55 |
| GPU | Mali-G52 MC2 |
| Memory | 6GB RAM |
| Android Version | 9.0 (Initial) / 12 (Current) |
| Release | July 2019 |

## Build Status

- **Working status:** Beta (in development)
- **TWRP version:** 3.7.1
- **Base (Manifest):** Android 12.1 (S)

### Features that DO work:
* [x] Touchscreen
* [x] Brightness
* [x] Vibration
* [x] Backup (unprotected partitions)

### Features that DO NOT work / Currently in development:
* [ ] **ADB / Sideload** — *current priority*
* [ ] **Partitions mounting (System, Vendor, Product)** — *current priority*
* [ ] **Data decryption (FBEv1)** — *current priority*
* [ ] MTP
* [ ] fastbootD

## Build Instructions

To build the image, use Arch Linux (recommended) or Ubuntu.

1. Initialize the manifest repo:
```bash
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
```

2. Clone this device tree to `device/vivo/1907N`

3. Launch the build:
```bash
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
lunch twrp_1907N-eng
mka recoveryimage -j$(nproc)
```
