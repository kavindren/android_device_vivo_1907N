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

// frameworks/base's BrightnessUtils.convertGammaToLinear() (Hybrid Log Gamma) is what turns
// the UI slider's raw 0..1 position into the linear brightness fraction that ends up, scaled
// to 0..255, as the luma in setLightState()'s color. It's a strong perceptual curve - gamma
// position 0.5 (the middle of the slider) maps to only ~8.3% linear, which on this panel reads
// as barely brighter than off. mirrorConvertLinearToGamma() below is BrightnessUtils's own
// convertLinearToGamma(), copied verbatim (same constants) - applying it to the linear luma we
// receive recovers the original 0..1 slider position, so scaling by that instead of by luma
// directly makes our output linear in slider position (half slider == half of mMaxBrightness),
// trading away the perceptual smoothing for a predictable, linear response.
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

    // luma (0..255) is already gamma-to-linear converted by the framework; recover the
    // original slider fraction and scale by that instead, so our output is linear in slider
    // position rather than in perceptual brightness. See mirrorConvertLinearToGamma() above.
    float sliderFraction = mirrorConvertLinearToGamma(static_cast<float>(luma) / 255.0f);
    int level = static_cast<int>(std::lround(sliderFraction * mMaxBrightness));
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
