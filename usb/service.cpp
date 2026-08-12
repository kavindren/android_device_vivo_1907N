/*
 * Copyright (C) 2016 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "android.hardware.usb.gadget@1.1-service.1907N"

#include <hidl/HidlTransportSupport.h>
#include "UsbGadget.h"

using android::sp;

// libhwbinder:
using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;

// Generated HIDL files
using android::hardware::usb::gadget::V1_1::IUsbGadget;
using android::hardware::usb::gadget::V1_1::implementation::UsbGadget;

using android::OK;
using android::status_t;

// IUsb (port role) is left to the stock vivo android.hardware.usb@1.2-service-mediatekv2
// blob (vendor.usb-hal-1-2), which registers it correctly - only IUsbGadget was broken/never
// completed registration on that blob, hanging UsbDeviceManager's constructor forever
// (IUsbGadget.getService(true) blocks). This service exists solely to provide a working
// IUsbGadget so UsbDeviceManager takes the HAL-based (UsbHandlerHal) path instead of
// UsbHandlerLegacy, which is hardcoded to the legacy /sys/class/android_usb/android0 sysfs
// gadget interface - confirmed present but read-only-stub (no enable/functions/idVendor/
// idProduct attributes at all, only state/iSerial/uevent) on this kernel, so UsbHandlerLegacy
// could never actually configure anything even though it can read android0/state.
int main() {
  android::sp<IUsbGadget> service = new UsbGadget();

  configureRpcThreadpool(2, true /*callerWillJoin*/);
  status_t status = service->registerAsService();

  if (status != OK) {
    ALOGE("Cannot register USB Gadget HAL service");
    return 1;
  }

  ALOGI("USB Gadget HAL Ready.");
  joinRpcThreadpool();
  // Under normal cases, execution will not reach this line.
  ALOGI("USB Gadget HAL failed to join thread pool.");
  return 1;
}
