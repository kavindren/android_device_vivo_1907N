#include "Lights.h"

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/strings.h>

#include <cmath>

namespace aidl {
namespace android {
namespace hardware {
namespace light {

static constexpr const char* kBacklightPath = "/sys/class/leds/lcd-backlight/brightness";
static constexpr const char* kMaxBacklightPath = "/sys/class/leds/lcd-backlight/max_brightness";
static constexpr int kDefaultMaxBrightness = 2047;

namespace {
constexpr float kHlgR = 0.5f;
constexpr float kHlgA = 0.17883277f;
constexpr float kHlgB = 0.28466892f;
constexpr float kHlgC = 0.55991073f;

float mirrorConvertLinearToGamma(float linear) {
    const float normalized = linear * 12.0f;
    if (normalized <= 1.0f) {
        return std::sqrt(normalized) * kHlgR;
    }
    return kHlgA * std::log(normalized - kHlgB) + kHlgC;
}

constexpr float kMinPivotOldFrac = 222.0f / 2047.0f;
constexpr float kMinPivotNewFrac = 50.0f / 2047.0f;

float remapLowEnd(float frac) {
    if (frac <= kMinPivotOldFrac) {
        return frac * (kMinPivotNewFrac / kMinPivotOldFrac);
    }
    return kMinPivotNewFrac + (frac - kMinPivotOldFrac) * (1.0f - kMinPivotNewFrac) /
                                      (1.0f - kMinPivotOldFrac);
}
}  // namespace

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

    float sliderFraction = mirrorConvertLinearToGamma(static_cast<float>(luma) / 255.0f);
    float remappedFraction = remapLowEnd(sliderFraction);
    int level = static_cast<int>(std::lround(remappedFraction * mMaxBrightness));
    if (level < 0) level = 0;
    if (level > mMaxBrightness) level = mMaxBrightness;

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
