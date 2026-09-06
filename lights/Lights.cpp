#include "Lights.h"

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/strings.h>

namespace aidl {
namespace android {
namespace hardware {
namespace light {

static constexpr const char* kBacklightPath = "/sys/class/leds/lcd-backlight/brightness";
static constexpr const char* kMaxBacklightPath = "/sys/class/leds/lcd-backlight/max_brightness";
static constexpr int kDefaultMaxBrightness = 2047;

Lights::Lights() : mMaxBrightness(kDefaultMaxBrightness) {
    std::string content;
    if (::android::base::ReadFileToString(kMaxBacklightPath, &content)) {
        int value = atoi(::android::base::Trim(content).c_str());
        if (value > 0) {
            mMaxBrightness = value;
        }
    } else {
        LOG(ERROR) << "Failed to read " << kMaxBacklightPath << ", assuming max_brightness="
                   << kDefaultMaxBrightness;
    }
    LOG(INFO) << "Lights HAL: backlight max_brightness = " << mMaxBrightness;
}

ndk::ScopedAStatus Lights::setLightState(int id, const HwLightState& state) {
    if (id != static_cast<int>(LightType::BACKLIGHT)) {
        return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    uint8_t luma = ((77 * ((state.color >> 16) & 0xff)) + (150 * ((state.color >> 8) & 0xff)) +
                    (29 * (state.color & 0xff))) >>
                   8;

    int level = (static_cast<int>(luma) * mMaxBrightness + 127) / 255;

    if (!::android::base::WriteStringToFile(std::to_string(level), kBacklightPath)) {
        LOG(ERROR) << "Failed to write " << level << " to " << kBacklightPath;
        return ndk::ScopedAStatus::fromExceptionCode(EX_ILLEGAL_STATE);
    }

    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Lights::getLights(std::vector<HwLight>* lights) {
    HwLight backlight{};
    backlight.id = static_cast<int>(LightType::BACKLIGHT);
    backlight.ordinal = 0;
    backlight.type = LightType::BACKLIGHT;
    lights->push_back(backlight);

    return ndk::ScopedAStatus::ok();
}

}  // namespace light
}  // namespace hardware
}  // namespace android
}  // namespace aidl
