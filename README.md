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
* [x] ADB / Sideload
* [x] Partitions mounting (System, Vendor, Product)

### Features that DO NOT work / Currently in development:

* [ ] **Data decryption (FBEv1)** - *current priority*
* [ ] MTP
* [ ] fastbootD

## Build Instructions

# WARNING! I am NOT responsible for any damage to your device. Use this TWRP at your own risk!

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

## How to flash the image?
Flashing recovery on Vivo devices can be challenging due to bootloader restrictions. Below are the tested methods:
1. Use SP Flash Tool with the MT6768 scatter
2. Unlock the bootloader

The first option is the easiest one, but there's high chance of bricking it. The `MT6768_Android_Scatter.txt` for V17 Neo / S1 is included in the repository

The second option is the most interesting one. You actually CAN unlock the bootloader, and there are three ways to do that:
1. [Rollback to Android 10 firmware, where the `fastboot flashing unlock` command isn't blocked](https://4pda.to/forum/index.php?showtopic=963689&st=440#entry100106035)
2. [Use special custom fastboot for vivo devices](https://4pda.to/forum/index.php?showtopic=1047450#entry114868014)
3. [Unlock the bootloader via testpoint and mtkclient](https://4pda.to/forum/index.php?showtopic=1047450&st=1100#entry139919639)

I have successfully unlocked the bootloader with the third method. IMHO it has the highest chance of being actually unlocked

## Credits
* [TeamWin](https://github.com/TeamWin/Team-Win-Recovery-Project) - For the Recovery Project (TWRP)
* [Minimal Manifest TWRP](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp) - For the building environment
* [4PDA Community](https://4pda.to/forum/index.php?showtopic=1047450) - For bootloader unlock methods and testing
