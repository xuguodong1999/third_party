/*
 * Copyright 2024 Google LLC
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

#include "include/gpu/graphite/precompile/PrecompileShader.h"

#include "include/core/SkColorSpace.h"
#include "include/effects/SkRuntimeEffect.h"
#include "include/gpu/graphite/precompile/PrecompileBlender.h"
#include "include/gpu/graphite/precompile/PrecompileColorFilter.h"
#include "src/core/SkColorSpacePriv.h"
#include "src/core/SkImageInfoPriv.h"
#include "src/core/SkKnownRuntimeEffects.h"
#include "src/gpu/Blend.h"
#include "src/gpu/graphite/BuiltInCodeSnippetID.h"
#include "src/gpu/graphite/KeyContext.h"
#include "src/gpu/graphite/KeyHelpers.h"
#include "src/gpu/graphite/PaintParams.h"
#include "src/gpu/graphite/PaintParamsKey.h"
#include "src/gpu/graphite/PrecompileInternal.h"
#include "src/gpu/graphite/ReadSwizzle.h"
#include "src/gpu/graphite/RecorderPriv.h"
#include "src/gpu/graphite/precompile/PrecompileBaseComplete.h"
#include "src/gpu/graphite/precompile/PrecompileBasePriv.h"
#include "src/gpu/graphite/precompile/PrecompileBlenderPriv.h"
#include "src/gpu/graphite/precompile/PrecompileShaderPriv.h"
#include "src/gpu/graphite/precompile/PrecompileShadersPriv.h"
#include "src/shaders/gradients/SkLinearGradient.h"

namespace skgpu::graphite {

PrecompileShader::~PrecompileShader() = default;

sk_sp<PrecompileShader> PrecompileShader::makeWithColorFilter(
        sk_sp<PrecompileColorFilter> cf) const {
    if (!cf) {
        return sk_ref_sp(this);
    }

    return PrecompileShaders::ColorFilter({ sk_ref_sp(this) }, { std::move(cf) });
}

sk_sp<PrecompileShader> PrecompileShader::makeWithWorkingColorSpace(sk_sp<SkColorSpace> cs) const {
    if (!cs) {
        return sk_ref_sp(this);
    }

    return PrecompileShaders::WorkingColorSpace({ sk_ref_sp(this) }, { std::move(cs) });
}

//--------------------------------------------------------------------------------------------------
class PrecompileEmptyShader final : public PrecompileShader {
private:
    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {

        SkASSERT(desiredCombination == 0); // The empty shader only ever has one combination

        builder->addBlock(BuiltInCodeSnippetID::kPriorOutput);
    }
};

sk_sp<PrecompileShader> PrecompileShaders::Empty() {
    return sk_make_sp<PrecompileEmptyShader>();
}

//--------------------------------------------------------------------------------------------------
class PrecompileColorShader final : public PrecompileShader {
private:
    bool isConstant(int desiredCombination) const override {
        SkASSERT(desiredCombination == 0); // The color shader only ever has one combination
        return true;
    }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {

        SkASSERT(desiredCombination == 0); // The color shader only ever has one combination

        // The white PMColor is just a placeholder for the actual paint params color
        SolidColorShaderBlock::AddBlock(keyContext, builder, gatherer, SK_PMColor4fWHITE);
    }
};

sk_sp<PrecompileShader> PrecompileShaders::Color() {
    return sk_make_sp<PrecompileColorShader>();
}

// The colorSpace is safe to ignore - it is just applied to the color and doesn't modify the
// generated program.
sk_sp<PrecompileShader> PrecompileShaders::Color(sk_sp<SkColorSpace>) {
    return sk_make_sp<PrecompileColorShader>();
}

//--------------------------------------------------------------------------------------------------
class PrecompileBlendShader final : public PrecompileShader {
public:
    PrecompileBlendShader(PrecompileBlenderList&& blenders,
                          SkSpan<const sk_sp<PrecompileShader>> dsts,
                          SkSpan<const sk_sp<PrecompileShader>> srcs)
            : fBlenderOptions(std::move(blenders))
            , fDstOptions(dsts.begin(), dsts.end())
            , fSrcOptions(srcs.begin(), srcs.end()) {
        fNumDstCombos = 0;
        for (const auto& d : fDstOptions) {
            fNumDstCombos += d->priv().numCombinations();
        }

        fNumSrcCombos = 0;
        for (const auto& s : fSrcOptions) {
            fNumSrcCombos += s->priv().numCombinations();
        }
    }

private:
    int numChildCombinations() const override {
        return fBlenderOptions.numCombinations() * fNumDstCombos * fNumSrcCombos;
    }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < this->numCombinations());

        const int desiredDstCombination = desiredCombination % fNumDstCombos;
        int remainingCombinations = desiredCombination / fNumDstCombos;

        const int desiredSrcCombination = remainingCombinations % fNumSrcCombos;
        remainingCombinations /= fNumSrcCombos;

        int desiredBlendCombination = remainingCombinations;
        SkASSERT(desiredBlendCombination < fBlenderOptions.numCombinations());

        auto [blender, blenderCombination] = fBlenderOptions.selectOption(desiredBlendCombination);
        if (blender->priv().asBlendMode()) {
            // Coefficient and HSLC blends, and other fixed SkBlendMode blenders use the
            // BlendCompose block to organize the children.
            BlendComposeBlock::BeginBlock(keyContext, builder, gatherer);
        } else {
            // Runtime blenders are wrapped in the kBlend runtime shader, although functionally
            // it is identical to the BlendCompose snippet.
            const SkRuntimeEffect* blendEffect =
                    GetKnownRuntimeEffect(SkKnownRuntimeEffects::StableKey::kBlend);

            RuntimeEffectBlock::BeginBlock(keyContext, builder, gatherer,
                                           { sk_ref_sp(blendEffect) });
        }

        AddToKey<PrecompileShader>(keyContext, builder, gatherer, fSrcOptions,
                                   desiredSrcCombination);
        AddToKey<PrecompileShader>(keyContext, builder, gatherer, fDstOptions,
                                   desiredDstCombination);

        if (blender->priv().asBlendMode()) {
            SkASSERT(blenderCombination == 0);
            AddBlendMode(keyContext, builder, gatherer, *blender->priv().asBlendMode());
        } else {
            blender->priv().addToKey(keyContext, builder, gatherer, blenderCombination);
        }

        builder->endBlock();  // BlendComposeBlock or RuntimeEffectBlock
    }

    PrecompileBlenderList fBlenderOptions;
    std::vector<sk_sp<PrecompileShader>> fDstOptions;
    std::vector<sk_sp<PrecompileShader>> fSrcOptions;

    int fNumDstCombos;
    int fNumSrcCombos;
};

sk_sp<PrecompileShader> PrecompileShaders::Blend(
        SkSpan<const sk_sp<PrecompileBlender>> blenders,
        SkSpan<const sk_sp<PrecompileShader>> dsts,
        SkSpan<const sk_sp<PrecompileShader>> srcs) {
    return sk_make_sp<PrecompileBlendShader>(PrecompileBlenderList(blenders), dsts, srcs);
}

sk_sp<PrecompileShader> PrecompileShaders::Blend(
        SkSpan<const SkBlendMode> blendModes,
        SkSpan<const sk_sp<PrecompileShader>> dsts,
        SkSpan<const sk_sp<PrecompileShader>> srcs) {
    return sk_make_sp<PrecompileBlendShader>(PrecompileBlenderList(blendModes), dsts, srcs);
}

//--------------------------------------------------------------------------------------------------
class PrecompileCoordClampShader final : public PrecompileShader {
public:
    PrecompileCoordClampShader(SkSpan<const sk_sp<PrecompileShader>> shaders)
            : fShaders(shaders.begin(), shaders.end()) {
        fNumShaderCombos = 0;
        for (const auto& s : fShaders) {
            fNumShaderCombos += s->priv().numCombinations();
        }
    }

private:
    int numChildCombinations() const override {
        return fNumShaderCombos;
    }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < fNumShaderCombos);

        constexpr SkRect kIgnored { 0, 0, 256, 256 }; // ignored bc we're precompiling

        // TODO: update CoordClampShaderBlock so this is optional
        CoordClampShaderBlock::CoordClampData data(kIgnored);

        CoordClampShaderBlock::BeginBlock(keyContext, builder, gatherer, data);
            AddToKey<PrecompileShader>(keyContext, builder, gatherer, fShaders, desiredCombination);
        builder->endBlock();
    }

    std::vector<sk_sp<PrecompileShader>> fShaders;
    int fNumShaderCombos;
};

sk_sp<PrecompileShader> PrecompileShaders::CoordClamp(SkSpan<const sk_sp<PrecompileShader>> input) {
    return sk_make_sp<PrecompileCoordClampShader>(input);
}

//--------------------------------------------------------------------------------------------------
class PrecompileImageShader final : public PrecompileShader {
public:
    PrecompileImageShader(SkEnumBitMask<PrecompileImageShaderFlags> flags,
                          SkSpan<const SkColorInfo> colorInfos,
                          SkSpan<const SkTileMode> tileModes,
                          bool raw)
            : fNumExtraSamplingTilingCombos((flags & PrecompileImageShaderFlags::kExcludeCubic)
                                                    ? 1  // Just kHWTiled
                                                    : kExtraNumSamplingTilingCombos)
            , fColorInfos(!colorInfos.empty()
                            ? std::vector<SkColorInfo>(colorInfos.begin(), colorInfos.end())
                            : raw ? RawImageDefaultColorInfos()
                                  : (flags & PrecompileImageShaderFlags::kExcludeAlpha)
                                             ? NonAlphaOnlyDefaultColorInfos()
                                             : DefaultColorInfos())
            , fTileModes(!tileModes.empty()
                            ? std::vector<SkTileMode>(tileModes.begin(), tileModes.end())
                            : DefaultTileModes())
            , fUseDstColorSpace(!colorInfos.empty())
            , fRaw(raw) {}

private:
    // In addition to the tile mode options provided by the client, we can precompile two additional
    // sampling/tiling variants: hardware-tiled and cubic sampling (which always uses the most
    // generic tiling shader).
    inline static constexpr int kExtraNumSamplingTilingCombos = 2;
    inline static constexpr int kCubicSampled = 1;
    inline static constexpr int kHWTiled      = 0;

    // These color info objects are defined assuming an sRGB destination.
    // Most specialized color space transform shader, no actual color space handling.
    static SkColorInfo DefaultColorInfoPremul() {
        return { kRGBA_8888_SkColorType, kPremul_SkAlphaType, SkColorSpace::MakeSRGB() };
    }
    // sRGB-to-sRGB specialized color space transform shader.
    static SkColorInfo DefaultColorInfoSRGB() {
        return { kRGBA_8888_SkColorType, kPremul_SkAlphaType,
                 sk_srgb_singleton()->makeColorSpin() };
    }
    // Most general color space transform shader.
    static SkColorInfo DefaultColorInfoGeneral() {
        return { kRGBA_8888_SkColorType, kPremul_SkAlphaType, SkColorSpace::MakeSRGBLinear() };
    }
    // Alpha-only, most general color space transform shader.
    static SkColorInfo DefaultColorInfoAlphaOnly() {
        return { kAlpha_8_SkColorType, kPremul_SkAlphaType, SkColorSpace::MakeSRGBLinear() };
    }

    // A fixed list of SkColorInfos that will trigger each possible combination of alpha-only
    // handling and color space transform variants, when drawn to an sRGB destination.
    static std::vector<SkColorInfo> DefaultColorInfos() {
        return { DefaultColorInfoPremul(), DefaultColorInfoSRGB(), DefaultColorInfoGeneral(),
                 DefaultColorInfoAlphaOnly() };
    }
    // A fixed list of SkColorInfos that will trigger each color space transform shader variant when
    // drawn to an sRGB destination.
    static std::vector<SkColorInfo> NonAlphaOnlyDefaultColorInfos() {
        return { DefaultColorInfoPremul(), DefaultColorInfoSRGB(), DefaultColorInfoGeneral() };
    }
    // A fixed list of SkColorInfos that will trigger each color space transform shader variant
    // possible from a raw image draw. The general shader is still required if the image is
    // alpha-only, because the read swizzle is implemented as a gamut transformation.
    static std::vector<SkColorInfo> RawImageDefaultColorInfos() {
        return { DefaultColorInfoPremul(), DefaultColorInfoAlphaOnly() };
    }

    // A fixed list of SkTileModes that will trigger each tiling shader variant.
    static std::vector<SkTileMode> DefaultTileModes() {
        return { SkTileMode::kClamp, SkTileMode::kRepeat };
    }

    const int fNumExtraSamplingTilingCombos;

    const std::vector<SkColorInfo> fColorInfos;
    const std::vector<SkTileMode> fTileModes;

    // If true, use the destination color space from the KeyContext provided to addToKey.
    // This is true if and only if the client has provided a list of color infos. Otherwise, we
    // always use an sRGB destination per the default SkColorInfo lists defined above.
    const bool fUseDstColorSpace;

    // Whether this precompiles raw image shaders.
    const bool fRaw;

    int numIntrinsicCombinations() const override {
        // TODO(b/400682634) If color infos were provided by the client, and we're using the
        // destination color space to determine what color space transform shaders to use, we can
        // end up generating duplicate shaders, and the actual number of unique shaders generated
        // will be less than the number calculated here.
        return fColorInfos.size() * (fTileModes.size() + fNumExtraSamplingTilingCombos);
    }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(this->numChildCombinations() == 1);
        SkASSERT(desiredCombination < this->numIntrinsicCombinations());

        const int numSamplingTilingCombos = fTileModes.size() + fNumExtraSamplingTilingCombos;
        const int desiredSamplingTilingCombo = desiredCombination % numSamplingTilingCombos;
        desiredCombination /= numSamplingTilingCombos;

        const int desiredColorInfo = desiredCombination;
        SkASSERT(desiredColorInfo < static_cast<int>(fColorInfos.size()));

        static constexpr SkSamplingOptions kDefaultCubicSampling(SkCubicResampler::Mitchell());
        static constexpr SkSamplingOptions kDefaultSampling;

        // ImageShaderBlock will use hardware tiling when the subset covers the entire image, so we
        // create subset + image size combinations where subset == imgSize (for a shader that uses
        // hardware tiling) and subset < imgSize (for a shader that does shader-based tiling).
        static constexpr SkRect kSubset = SkRect::MakeWH(1.0f, 1.0f);
        static constexpr SkISize kHWTileableSize = SkISize::Make(1, 1);
        static constexpr SkISize kShaderTileableSize = SkISize::Make(2, 2);

        const int numTileModes = fTileModes.size();
        const SkTileMode tileMode = (desiredSamplingTilingCombo < numTileModes)
                                            ? fTileModes[desiredSamplingTilingCombo]
                                            : SkTileMode::kClamp;
        const SkISize imgSize = (desiredSamplingTilingCombo >= numTileModes &&
                                 desiredSamplingTilingCombo - numTileModes == kHWTiled)
                                        ? kHWTileableSize
                                        : kShaderTileableSize;
        const SkSamplingOptions sampling =
                (desiredSamplingTilingCombo >= numTileModes &&
                 desiredSamplingTilingCombo - numTileModes == kCubicSampled)
                        ? kDefaultCubicSampling
                        : kDefaultSampling;

        const ImageShaderBlock::ImageData imgData(sampling, tileMode, tileMode, imgSize, kSubset);

        const SkColorInfo& colorInfo = fColorInfos[desiredColorInfo];
        const bool alphaOnly = SkColorTypeIsAlphaOnly(colorInfo.colorType());

        const Caps* caps = keyContext.caps();
        Swizzle readSwizzle = caps->getReadSwizzle(
                colorInfo.colorType(),
                caps->getDefaultSampledTextureInfo(
                        colorInfo.colorType(), Mipmapped::kNo, Protected::kNo, Renderable::kNo));
        if (alphaOnly) {
            readSwizzle = Swizzle::Concat(readSwizzle, Swizzle("000a"));
        }

        ColorSpaceTransformBlock::ColorSpaceTransformData colorXformData(
                SwizzleClassToReadEnum(readSwizzle));

        if (!fRaw) {
            const SkColorSpace* dstColorSpace = fUseDstColorSpace
                                                        ? keyContext.dstColorInfo().colorSpace()
                                                        : sk_srgb_singleton();
            colorXformData.fSteps = SkColorSpaceXformSteps(
                    colorInfo.colorSpace(), colorInfo.alphaType(),
                    dstColorSpace, colorInfo.alphaType());

            if (alphaOnly) {
                Blend(keyContext, builder, gatherer,
                      /* addBlendToKey= */ [&] () -> void {
                          AddFixedBlendMode(keyContext, builder, gatherer, SkBlendMode::kDstIn);
                      },
                      /* addSrcToKey= */ [&] () -> void {
                          Compose(keyContext, builder, gatherer,
                                  /* addInnerToKey= */ [&]() -> void {
                                      ImageShaderBlock::AddBlock(keyContext, builder, gatherer,
                                                                 imgData);
                                  },
                                  /* addOuterToKey= */ [&]() -> void {
                                      ColorSpaceTransformBlock::AddBlock(keyContext, builder,
                                                                         gatherer, colorXformData);
                                  });
                      },
                      /* addDstToKey= */ [&]() -> void {
                          RGBPaintColorBlock::AddBlock(keyContext, builder, gatherer);
                      });
                return;
            }
        }

        Compose(keyContext, builder, gatherer,
                /* addInnerToKey= */ [&]() -> void {
                    ImageShaderBlock::AddBlock(keyContext, builder, gatherer, imgData);
                },
                /* addOuterToKey= */ [&]() -> void {
                    ColorSpaceTransformBlock::AddBlock(keyContext, builder, gatherer,
                                                       colorXformData);
                });
    }
};

sk_sp<PrecompileShader> PrecompileShaders::Image(SkSpan<const SkColorInfo> colorInfos,
                                                 SkSpan<const SkTileMode> tileModes) {
    return PrecompileShaders::LocalMatrix(
            { sk_make_sp<PrecompileImageShader>(PrecompileImageShaderFlags::kNone,
                                                colorInfos, tileModes,
                                                /* raw= */false) });
}

sk_sp<PrecompileShader> PrecompileShaders::RawImage(SkSpan<const SkColorInfo> colorInfos,
                                                    SkSpan<const SkTileMode> tileModes) {
    return PrecompileShaders::LocalMatrix(
            { sk_make_sp<PrecompileImageShader>(PrecompileImageShaderFlags::kExcludeCubic,
                                                colorInfos, tileModes,
                                                /* raw= */true) });
}

sk_sp<PrecompileShader> PrecompileShadersPriv::Image(
        SkEnumBitMask<PrecompileImageShaderFlags> flags) {
    return PrecompileShaders::LocalMatrix(
            { sk_make_sp<PrecompileImageShader>(flags,
                                                SkSpan<const SkColorInfo>(),
                                                SkSpan<const SkTileMode>(),
                                                /* raw= */ false) });
}

sk_sp<PrecompileShader> PrecompileShadersPriv::RawImage(
        SkEnumBitMask<PrecompileImageShaderFlags> flags) {
    return PrecompileShaders::LocalMatrix(
            { sk_make_sp<PrecompileImageShader>(flags | PrecompileImageShaderFlags::kExcludeCubic,
                                                SkSpan<const SkColorInfo>(),
                                                SkSpan<const SkTileMode>(),
                                                /* raw= */ true) });
}

//--------------------------------------------------------------------------------------------------
class PrecompileYUVImageShader : public PrecompileShader {
public:
    PrecompileYUVImageShader() {}

private:
    // There are 12 intrinsic YUV shaders:
    //  4 tiling modes
    //    HW tiling w/o swizzle
    //    HW tiling w/ swizzle
    //    cubic shader tiling
    //    non-cubic shader tiling
    //  crossed with 3 color space transforms:
    //    premul/alpha-swizzle only
    //    srgb-to-srgb
    //    general transform
    inline static constexpr int kNumTilingModes     = 4;
    inline static constexpr int kHWTiledNoSwizzle   = 3;
    inline static constexpr int kHWTiledWithSwizzle = 2;
    inline static constexpr int kCubicShaderTiled   = 1;
    inline static constexpr int kShaderTiled        = 0;

    inline static constexpr int kNumColorSpaceCombinations = 3;
    inline static constexpr int kColorSpacePremul  = 2;
    inline static constexpr int kColorSpaceSRGB    = 1;
    inline static constexpr int kColorSpaceGeneral = 0;

    inline static constexpr int kNumIntrinsicCombinations =
            kNumTilingModes * kNumColorSpaceCombinations;

    int numIntrinsicCombinations() const override { return kNumIntrinsicCombinations; }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < kNumIntrinsicCombinations);

        int desiredColorSpaceCombo = desiredCombination % kNumColorSpaceCombinations;
        int desiredTiling = desiredCombination / kNumColorSpaceCombinations;
        SkASSERT(desiredTiling < kNumTilingModes);

        static constexpr SkSamplingOptions kDefaultCubicSampling(SkCubicResampler::Mitchell());
        static constexpr SkSamplingOptions kDefaultSampling;

        YUVImageShaderBlock::ImageData imgData(desiredTiling == kCubicShaderTiled
                                                                       ? kDefaultCubicSampling
                                                                       : kDefaultSampling,
                                               SkTileMode::kClamp, SkTileMode::kClamp,
                                               /* imgSize= */ { 1, 1 },
                                               /* subset= */ desiredTiling == kShaderTiled
                                                                     ? SkRect::MakeEmpty()
                                                                     : SkRect::MakeWH(1, 1));

        static constexpr SkV4 kRedChannel{ 1.f, 0.f, 0.f, 0.f };
        imgData.fChannelSelect[0] = kRedChannel;
        imgData.fChannelSelect[1] = kRedChannel;
        if (desiredTiling == kHWTiledNoSwizzle) {
            imgData.fChannelSelect[2] = kRedChannel;
        } else {
            // Having a non-red channel selector forces a swizzle
            imgData.fChannelSelect[2] = { 0.f, 1.f, 0.f, 0.f};
        }
        imgData.fChannelSelect[3] = kRedChannel;

        imgData.fYUVtoRGBMatrix.setAll(1, 0, 0, 0, 1, 0, 0, 0, 0);
        imgData.fYUVtoRGBTranslate = { 0, 0, 0 };

        static sk_sp<SkColorSpace> srgbSpinColorSpace = sk_srgb_singleton()->makeColorSpin();
        const ColorSpaceTransformBlock::ColorSpaceTransformData colorXformData =
                desiredColorSpaceCombo == kColorSpacePremul
                        ? ColorSpaceTransformBlock::ColorSpaceTransformData(
                                  skgpu::graphite::ReadSwizzle::kRGB1) :
                desiredColorSpaceCombo == kColorSpaceSRGB
                        ? ColorSpaceTransformBlock::ColorSpaceTransformData(
                                  sk_srgb_singleton(), kPremul_SkAlphaType,
                                  srgbSpinColorSpace.get(), kPremul_SkAlphaType)
                        : ColorSpaceTransformBlock::ColorSpaceTransformData(
                                  sk_srgb_singleton(), kPremul_SkAlphaType,
                                  sk_srgb_linear_singleton(), kPremul_SkAlphaType);
        Compose(keyContext, builder, gatherer,
                /* addInnerToKey= */ [&]() -> void {
                    YUVImageShaderBlock::AddBlock(keyContext, builder, gatherer, imgData);
                },
                /* addOuterToKey= */ [&]() -> void {
                    ColorSpaceTransformBlock::AddBlock(keyContext, builder, gatherer,
                                                       colorXformData);
                });
    }
};

sk_sp<PrecompileShader> PrecompileShaders::YUVImage() {
    return PrecompileShaders::LocalMatrix({ sk_make_sp<PrecompileYUVImageShader>() });
}

//--------------------------------------------------------------------------------------------------
class PrecompilePerlinNoiseShader final : public PrecompileShader {
public:
    PrecompilePerlinNoiseShader() {}

private:
    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {

        SkASSERT(desiredCombination == 0); // The Perlin noise shader only ever has one combination

        // TODO: update PerlinNoiseShaderBlock so the NoiseData is optional
        static const PerlinNoiseShaderBlock::PerlinNoiseData kIgnoredNoiseData(
                PerlinNoiseShaderBlock::Type::kFractalNoise, { 0.0f, 0.0f }, 2, {1, 1});

        PerlinNoiseShaderBlock::AddBlock(keyContext, builder, gatherer, kIgnoredNoiseData);
    }

};

sk_sp<PrecompileShader> PrecompileShaders::MakeFractalNoise() {
    return sk_make_sp<PrecompilePerlinNoiseShader>();
}

sk_sp<PrecompileShader> PrecompileShaders::MakeTurbulence() {
    return sk_make_sp<PrecompilePerlinNoiseShader>();
}

namespace {

sk_sp<SkColorSpace> get_gradient_intermediate_cs(SkColorSpace* dstColorSpace,
                                                 SkGradientShader::Interpolation interpolation) {
    // Any gradient shader will do, as long as it has the correct interpolation settings.
    constexpr SkPoint pts[2] = {{0.f, 0.f}, {1.f, 0.f}};
    constexpr SkColor4f colors[2] = {SkColors::kBlack, SkColors::kWhite};
    constexpr float pos[2] = {0.f, 1.f};
    SkLinearGradient shader(pts, {colors, nullptr, pos, 2, SkTileMode::kClamp, interpolation});

    SkColor4fXformer xformedColors(&shader, dstColorSpace);
    return xformedColors.fIntermediateColorSpace;
}

}  // anonymous namespace

//--------------------------------------------------------------------------------------------------
class PrecompileGradientShader final : public PrecompileShader {
public:
    PrecompileGradientShader(SkShaderBase::GradientType type,
                             const SkGradientShader::Interpolation& interpolation)
            : fType(type), fInterpolation(interpolation) {}

private:
    /*
     * The gradients currently have three specializations based on the number of stops.
     */
    inline static constexpr int kNumStopVariants = 3;
    inline static constexpr int kStopVariants[kNumStopVariants] =
            { 4, 8, GradientShaderBlocks::GradientData::kNumInternalStorageStops+1 };

    int numIntrinsicCombinations() const override { return kNumStopVariants; }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(this->numChildCombinations() == 1);
        SkASSERT(desiredCombination < kNumStopVariants);

        bool useStorageBuffer = keyContext.caps()->gradientBufferSupport();

        GradientShaderBlocks::GradientData gradData(fType,
                                                    kStopVariants[desiredCombination],
                                                    useStorageBuffer);

        // The logic for setting up color spaces here should match that in the "add_gradient_to_key"
        // functions from src/gpu/graphite/KeyHelpers.cpp.
        sk_sp<SkColorSpace> intermediateCS = get_gradient_intermediate_cs(
                keyContext.dstColorInfo().colorSpace(), fInterpolation);
        const SkColorSpace* dstCS = keyContext.dstColorInfo().colorSpace()
                                            ? keyContext.dstColorInfo().colorSpace()
                                            : sk_srgb_singleton();

        ColorSpaceTransformBlock::ColorSpaceTransformData csData(
                intermediateCS.get(), kPremul_SkAlphaType,
                dstCS, kPremul_SkAlphaType);

        Compose(keyContext, builder, gatherer,
                /* addInnerToKey= */ [&]() -> void {
                    GradientShaderBlocks::AddBlock(keyContext, builder, gatherer, gradData);
                },
                /* addOuterToKey= */  [&]() -> void {
                    ColorSpaceTransformBlock::AddBlock(keyContext, builder, gatherer, csData);
                });
    }

    const SkShaderBase::GradientType fType;
    const SkGradientShader::Interpolation fInterpolation;
};

sk_sp<PrecompileShader> PrecompileShaders::LinearGradient(
        SkGradientShader::Interpolation interpolation) {
    sk_sp<PrecompileShader> s = sk_make_sp<PrecompileGradientShader>(
            SkShaderBase::GradientType::kLinear, interpolation);
    return PrecompileShaders::LocalMatrix({ std::move(s) });
}

sk_sp<PrecompileShader> PrecompileShaders::RadialGradient(
        SkGradientShader::Interpolation interpolation) {
    sk_sp<PrecompileShader> s = sk_make_sp<PrecompileGradientShader>(
            SkShaderBase::GradientType::kRadial, interpolation);
    return PrecompileShaders::LocalMatrix({ std::move(s) });
}

sk_sp<PrecompileShader> PrecompileShaders::SweepGradient(
        SkGradientShader::Interpolation interpolation) {
    sk_sp<PrecompileShader> s =
            sk_make_sp<PrecompileGradientShader>(SkShaderBase::GradientType::kSweep, interpolation);
    return PrecompileShaders::LocalMatrix({ std::move(s) });
}

sk_sp<PrecompileShader> PrecompileShaders::TwoPointConicalGradient(
        SkGradientShader::Interpolation interpolation) {
    sk_sp<PrecompileShader> s = sk_make_sp<PrecompileGradientShader>(
            SkShaderBase::GradientType::kConical, interpolation);
    return PrecompileShaders::LocalMatrix({ std::move(s) });
}

//--------------------------------------------------------------------------------------------------
// The PictureShader ultimately turns into an SkImageShader optionally wrapped in a
// LocalMatrixShader.
// Note that this means each precompile PictureShader will add 24 combinations:
//    2 (pictureshader LM) x 12 (imageShader variations)
sk_sp<PrecompileShader> PrecompileShaders::Picture() {
    // Note: We don't need to consider the PrecompileYUVImageShader since the image
    // being drawn was created internally by Skia (as non-YUV).
    return PrecompileShadersPriv::LocalMatrixBothVariants({ PrecompileShaders::Image() });
}

sk_sp<PrecompileShader> PrecompileShadersPriv::Picture(bool withLM) {
    sk_sp<PrecompileShader> s = PrecompileShaders::Image();
    if (withLM) {
        return PrecompileShaders::LocalMatrix({ std::move(s) });
    }
    return s;
}

//--------------------------------------------------------------------------------------------------
// In the main Skia API the SkLocalMatrixShader is optimized away when the LM is the identity
// or omitted. The PrecompileLocalMatrixShader captures this by adding two intrinsic options.
// One with the LMShader wrapping the child and one without the LMShader.
class PrecompileLocalMatrixShader final : public PrecompileShader {
public:
    enum class Flags {
        kNone                  = 0b00,
        kIsPerspective         = 0b01,
        kIncludeWithOutVariant = 0b10,
    };

    PrecompileLocalMatrixShader(SkSpan<const sk_sp<PrecompileShader>> wrapped,
                                SkEnumBitMask<Flags> flags = Flags::kNone)
            : fWrapped(wrapped.begin(), wrapped.end())
            , fFlags(flags) {
        fNumWrappedCombos = 0;
        for (const auto& s : fWrapped) {
            fNumWrappedCombos += s->priv().numCombinations();
        }
    }

    bool isConstant(int desiredCombination) const override {
        SkASSERT(desiredCombination < this->numCombinations());

        /*
         * Regardless of whether the LocalMatrixShader elides itself or not, we always want
         * the Constant-ness of the wrapped shader.
         */
        int desiredWrappedCombination = desiredCombination / kNumIntrinsicCombinations;
        SkASSERT(desiredWrappedCombination < fNumWrappedCombos);

        std::pair<sk_sp<PrecompileShader>, int> wrapped =
                PrecompileBase::SelectOption(SkSpan(fWrapped), desiredWrappedCombination);
        if (wrapped.first) {
            return wrapped.first->priv().isConstant(wrapped.second);
        }

        return false;
    }

    SkSpan<const sk_sp<PrecompileShader>> getWrapped() const {
        return fWrapped;
    }

    SkEnumBitMask<Flags> getFlags() const { return fFlags; }

private:
    // The LocalMatrixShader has two potential variants: with and without the LocalMatrixShader
    // In the "with" variant, the kIsPerspective flag will determine if the shader performs
    // the perspective division or not.
    inline static constexpr int kNumIntrinsicCombinations = 2;
    inline static constexpr int kWithLocalMatrix    = 1;
    inline static constexpr int kWithoutLocalMatrix = 0;

    bool isALocalMatrixShader() const override { return true; }

    int numIntrinsicCombinations() const override {
        if (!(fFlags & Flags::kIncludeWithOutVariant)) {
            return 1;   // just kWithLocalMatrix
        }
        return kNumIntrinsicCombinations;
    }

    int numChildCombinations() const override { return fNumWrappedCombos; }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < this->numCombinations());

        int desiredLMCombination, desiredWrappedCombination;

        if (!(fFlags & Flags::kIncludeWithOutVariant)) {
            desiredLMCombination = kWithLocalMatrix;
            desiredWrappedCombination = desiredCombination;
        } else {
            desiredLMCombination = desiredCombination % kNumIntrinsicCombinations;
            desiredWrappedCombination = desiredCombination / kNumIntrinsicCombinations;
        }
        SkASSERT(desiredWrappedCombination < fNumWrappedCombos);

        if (desiredLMCombination == kWithLocalMatrix) {
            SkMatrix matrix = SkMatrix::I();
            if (fFlags & Flags::kIsPerspective) {
                matrix.setPerspX(0.1f);
            }
            LocalMatrixShaderBlock::LMShaderData lmShaderData(matrix);

            LocalMatrixShaderBlock::BeginBlock(keyContext, builder, gatherer, matrix);
        }

        AddToKey<PrecompileShader>(keyContext, builder, gatherer, fWrapped,
                                   desiredWrappedCombination);

        if (desiredLMCombination == kWithLocalMatrix) {
            builder->endBlock();
        }
    }

    std::vector<sk_sp<PrecompileShader>> fWrapped;
    int fNumWrappedCombos;
    SkEnumBitMask<Flags> fFlags;
};

sk_sp<PrecompileShader> PrecompileShaders::LocalMatrix(
        SkSpan<const sk_sp<PrecompileShader>> wrapped,
        bool isPerspective) {
    return sk_make_sp<PrecompileLocalMatrixShader>(
            std::move(wrapped),
            isPerspective ? PrecompileLocalMatrixShader::Flags::kIsPerspective
                          : PrecompileLocalMatrixShader::Flags::kNone);
}

sk_sp<PrecompileShader> PrecompileShadersPriv::LocalMatrixBothVariants(
        SkSpan<const sk_sp<PrecompileShader>> wrapped) {
    return sk_make_sp<PrecompileLocalMatrixShader>(
            std::move(wrapped),
            PrecompileLocalMatrixShader::Flags::kIncludeWithOutVariant);
}

sk_sp<PrecompileShader> PrecompileShader::makeWithLocalMatrix(bool isPerspective) const {
    if (this->priv().isALocalMatrixShader()) {
        // SkShader::makeWithLocalMatrix collapses chains of localMatrix shaders so we need to
        // follow suit here, folding in any new perspective flag if needed.
        auto thisAsLMShader = static_cast<const PrecompileLocalMatrixShader*>(this);
        if (isPerspective && !(thisAsLMShader->getFlags() &
                PrecompileLocalMatrixShader::Flags::kIsPerspective)) {
            return sk_make_sp<PrecompileLocalMatrixShader>(
                thisAsLMShader->getWrapped(),
                thisAsLMShader->getFlags() | PrecompileLocalMatrixShader::Flags::kIsPerspective);
        }

        return sk_ref_sp(this);
    }

    return PrecompileShaders::LocalMatrix({ sk_ref_sp(this) }, isPerspective);
}

//--------------------------------------------------------------------------------------------------
class PrecompileColorFilterShader final : public PrecompileShader {
public:
    PrecompileColorFilterShader(SkSpan<const sk_sp<PrecompileShader>> shaders,
                                SkSpan<const sk_sp<PrecompileColorFilter>> colorFilters)
            : fShaders(shaders.begin(), shaders.end())
            , fColorFilters(colorFilters.begin(), colorFilters.end()) {
        fNumShaderCombos = 0;
        for (const auto& s : fShaders) {
            fNumShaderCombos += s->priv().numCombinations();
        }
        fNumColorFilterCombos = 0;
        for (const auto& cf : fColorFilters) {
            fNumColorFilterCombos += cf->priv().numCombinations();
        }
    }

private:
    int numChildCombinations() const override { return fNumShaderCombos * fNumColorFilterCombos; }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < this->numCombinations());

        int desiredShaderCombination = desiredCombination % fNumShaderCombos;
        int desiredColorFilterCombination = desiredCombination / fNumShaderCombos;
        SkASSERT(desiredColorFilterCombination < fNumColorFilterCombos);

        Compose(keyContext, builder, gatherer,
                /* addInnerToKey= */ [&]() -> void {
                    AddToKey<PrecompileShader>(keyContext, builder, gatherer, fShaders,
                                               desiredShaderCombination);
                },
                /* addOuterToKey= */ [&]() -> void {
                    AddToKey<PrecompileColorFilter>(keyContext, builder, gatherer, fColorFilters,
                                                    desiredColorFilterCombination);
                });
    }

    std::vector<sk_sp<PrecompileShader>>      fShaders;
    std::vector<sk_sp<PrecompileColorFilter>> fColorFilters;
    int fNumShaderCombos;
    int fNumColorFilterCombos;
};

sk_sp<PrecompileShader> PrecompileShaders::ColorFilter(
        SkSpan<const sk_sp<PrecompileShader>> shaders,
        SkSpan<const sk_sp<PrecompileColorFilter>> colorFilters) {
    return sk_make_sp<PrecompileColorFilterShader>(std::move(shaders), std::move(colorFilters));
}

//--------------------------------------------------------------------------------------------------
class PrecompileWorkingColorSpaceShader final : public PrecompileShader {
public:
    PrecompileWorkingColorSpaceShader(SkSpan<const sk_sp<PrecompileShader>> shaders,
                                      SkSpan<const sk_sp<SkColorSpace>> colorSpaces)
            : fShaders(shaders.begin(), shaders.end())
            , fColorSpaces(colorSpaces.begin(), colorSpaces.end()) {
        fNumShaderCombos = 0;
        for (const auto& s : fShaders) {
            fNumShaderCombos += s->priv().numCombinations();
        }
    }

private:
    int numChildCombinations() const override { return fNumShaderCombos * fColorSpaces.size(); }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < this->numCombinations());

        int desiredShaderCombination = desiredCombination % fNumShaderCombos;
        int desiredColorSpaceCombination = desiredCombination / fNumShaderCombos;
        SkASSERT(desiredColorSpaceCombination < (int) fColorSpaces.size());

        const SkColorInfo& dstInfo = keyContext.dstColorInfo();
        const SkAlphaType dstAT = dstInfo.alphaType();
        sk_sp<SkColorSpace> dstCS = dstInfo.refColorSpace();
        if (!dstCS) {
            dstCS = SkColorSpace::MakeSRGB();
        }

        sk_sp<SkColorSpace> workingCS = fColorSpaces[desiredColorSpaceCombination];
        SkColorInfo workingInfo(dstInfo.colorType(), dstAT, workingCS);
        KeyContextWithColorInfo workingContext(keyContext, workingInfo);

        Compose(keyContext, builder, gatherer,
                /* addInnerToKey= */ [&]() -> void {
                    AddToKey<PrecompileShader>(keyContext, builder, gatherer, fShaders,
                                               desiredShaderCombination);
                },
                /* addOuterToKey= */ [&]() -> void {
                    ColorSpaceTransformBlock::ColorSpaceTransformData data(
                            workingCS.get(), dstAT, dstCS.get(), dstAT);
                    ColorSpaceTransformBlock::AddBlock(keyContext, builder, gatherer, data);
                });
    }

    std::vector<sk_sp<PrecompileShader>> fShaders;
    std::vector<sk_sp<SkColorSpace>>     fColorSpaces;
    int fNumShaderCombos;
};

sk_sp<PrecompileShader> PrecompileShaders::WorkingColorSpace(
        SkSpan<const sk_sp<PrecompileShader>> shaders,
        SkSpan<const sk_sp<SkColorSpace>> colorSpaces) {
    return sk_make_sp<PrecompileWorkingColorSpaceShader>(std::move(shaders),
                                                         std::move(colorSpaces));
}

//--------------------------------------------------------------------------------------------------
// In Graphite this acts as a non-elidable LocalMatrixShader
class PrecompileCTMShader final : public PrecompileShader {
public:
    PrecompileCTMShader(SkSpan<const sk_sp<PrecompileShader>> wrapped)
            : fWrapped(wrapped.begin(), wrapped.end()) {
        fNumWrappedCombos = 0;
        for (const auto& s : fWrapped) {
            fNumWrappedCombos += s->priv().numCombinations();
        }
    }

    bool isConstant(int desiredCombination) const override {
        SkASSERT(desiredCombination < fNumWrappedCombos);

        std::pair<sk_sp<PrecompileShader>, int> wrapped =
                PrecompileBase::SelectOption(SkSpan(fWrapped), desiredCombination);
        if (wrapped.first) {
            return wrapped.first->priv().isConstant(wrapped.second);
        }

        return false;
    }

private:
    int numChildCombinations() const override { return fNumWrappedCombos; }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < fNumWrappedCombos);

        LocalMatrixShaderBlock::LMShaderData kIgnoredLMShaderData(SkMatrix::I());

        LocalMatrixShaderBlock::BeginBlock(keyContext, builder, gatherer, kIgnoredLMShaderData);

            AddToKey<PrecompileShader>(keyContext, builder, gatherer, fWrapped, desiredCombination);

        builder->endBlock();
    }

    std::vector<sk_sp<PrecompileShader>> fWrapped;
    int fNumWrappedCombos;
};

sk_sp<PrecompileShader> PrecompileShadersPriv::CTM(SkSpan<const sk_sp<PrecompileShader>> wrapped) {
    return sk_make_sp<PrecompileCTMShader>(std::move(wrapped));
}

//--------------------------------------------------------------------------------------------------
class PrecompileBlurShader final : public PrecompileShader {
public:
    PrecompileBlurShader(sk_sp<PrecompileShader> wrapped)
            : fWrapped(std::move(wrapped)) {
        fNumWrappedCombos = fWrapped->priv().numCombinations();
    }

private:
    // 6 known 1D blur effects + 6 known 2D blur effects
    inline static constexpr int kNumIntrinsicCombinations = 12;

    int numIntrinsicCombinations() const override { return kNumIntrinsicCombinations; }

    int numChildCombinations() const override { return fNumWrappedCombos; }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < this->numCombinations());

        using namespace SkKnownRuntimeEffects;

        int desiredBlurCombination = desiredCombination % kNumIntrinsicCombinations;
        int desiredWrappedCombination = desiredCombination / kNumIntrinsicCombinations;
        SkASSERT(desiredWrappedCombination < fNumWrappedCombos);

        static const StableKey kIDs[kNumIntrinsicCombinations] = {
                StableKey::k1DBlur4,  StableKey::k1DBlur8,  StableKey::k1DBlur12,
                StableKey::k1DBlur16, StableKey::k1DBlur20, StableKey::k1DBlur28,

                StableKey::k2DBlur4,  StableKey::k2DBlur8,  StableKey::k2DBlur12,
                StableKey::k2DBlur16, StableKey::k2DBlur20, StableKey::k2DBlur28,
        };

        const SkRuntimeEffect* fEffect = GetKnownRuntimeEffect(kIDs[desiredBlurCombination]);

        KeyContextWithScope childContext(keyContext, KeyContext::Scope::kRuntimeEffect);

        RuntimeEffectBlock::BeginBlock(keyContext, builder, gatherer, { sk_ref_sp(fEffect) });
            fWrapped->priv().addToKey(childContext, builder, gatherer, desiredWrappedCombination);
        builder->endBlock();
    }

    sk_sp<PrecompileShader> fWrapped;
    int fNumWrappedCombos;
};

sk_sp<PrecompileShader> PrecompileShadersPriv::Blur(sk_sp<PrecompileShader> wrapped) {
    return sk_make_sp<PrecompileBlurShader>(std::move(wrapped));
}

//--------------------------------------------------------------------------------------------------
class PrecompileMatrixConvolutionShader final : public PrecompileShader {
public:
    PrecompileMatrixConvolutionShader(sk_sp<PrecompileShader> wrapped)
            : fWrapped(std::move(wrapped)) {
        fNumWrappedCombos = fWrapped->priv().numCombinations();

        // When the matrix convolution ImageFilter uses a texture we know it will only ever
        // be SkFilterMode::kNearest and SkTileMode::kClamp.
        // TODO: add a PrecompileImageShaderFlags to further limit the raw image shader
        // combinations. Right now we're getting two combinations for the raw shader
        // (sk_image_shader and sk_hw_image_shader).
        fRawImageShader =
                PrecompileShadersPriv::RawImage(PrecompileImageShaderFlags::kExcludeCubic);
        fNumRawImageShaderCombos = fRawImageShader->priv().numCombinations();
    }

private:
    int numIntrinsicCombinations() const override {
        // The uniform version only has one option but the two texture-based versions will
        // have as many combinations as the raw image shader.
        return 1 + 2 * fNumRawImageShaderCombos;
    }

    int numChildCombinations() const override { return fNumWrappedCombos; }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {

        int desiredTextureCombination = 0;

        const int desiredWrappedCombination = desiredCombination % fNumWrappedCombos;
        int remainingCombinations = desiredCombination / fNumWrappedCombos;

        SkKnownRuntimeEffects::StableKey stableKey = SkKnownRuntimeEffects::StableKey::kInvalid;
        if (remainingCombinations == 0) {
            stableKey = SkKnownRuntimeEffects::StableKey::kMatrixConvUniforms;
        } else {
            static constexpr SkKnownRuntimeEffects::StableKey kTextureBasedStableKeys[] = {
                    SkKnownRuntimeEffects::StableKey::kMatrixConvTexSm,
                    SkKnownRuntimeEffects::StableKey::kMatrixConvTexLg,
            };

            --remainingCombinations;
            stableKey = kTextureBasedStableKeys[remainingCombinations % 2];
            desiredTextureCombination = remainingCombinations / 2;
            SkASSERT(desiredTextureCombination < fNumRawImageShaderCombos);
        }

        const SkRuntimeEffect* fEffect = GetKnownRuntimeEffect(stableKey);

        KeyContextWithScope childContext(keyContext, KeyContext::Scope::kRuntimeEffect);

        RuntimeEffectBlock::BeginBlock(keyContext, builder, gatherer, { sk_ref_sp(fEffect) });
            fWrapped->priv().addToKey(childContext, builder, gatherer, desiredWrappedCombination);
            if (stableKey != SkKnownRuntimeEffects::StableKey::kMatrixConvUniforms) {
                fRawImageShader->priv().addToKey(childContext, builder, gatherer,
                                                 desiredTextureCombination);
            }
        builder->endBlock();
    }

    sk_sp<PrecompileShader> fWrapped;
    int fNumWrappedCombos;
    sk_sp<PrecompileShader> fRawImageShader;
    int fNumRawImageShaderCombos;
};

sk_sp<PrecompileShader> PrecompileShadersPriv::MatrixConvolution(
        sk_sp<skgpu::graphite::PrecompileShader> wrapped) {
    return sk_make_sp<PrecompileMatrixConvolutionShader>(std::move(wrapped));
}

//--------------------------------------------------------------------------------------------------
class PrecompileMorphologyShader final : public PrecompileShader {
public:
    PrecompileMorphologyShader(sk_sp<PrecompileShader> wrapped,
                               SkKnownRuntimeEffects::StableKey stableKey)
            : fWrapped(std::move(wrapped))
            , fStableKey(stableKey) {
        fNumWrappedCombos = fWrapped->priv().numCombinations();
        SkASSERT(stableKey == SkKnownRuntimeEffects::StableKey::kLinearMorphology ||
                 stableKey == SkKnownRuntimeEffects::StableKey::kSparseMorphology);
    }

private:
    int numChildCombinations() const override { return fNumWrappedCombos; }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < fNumWrappedCombos);

        const SkRuntimeEffect* effect = GetKnownRuntimeEffect(fStableKey);

        KeyContextWithScope childContext(keyContext, KeyContext::Scope::kRuntimeEffect);

        RuntimeEffectBlock::BeginBlock(keyContext, builder, gatherer, { sk_ref_sp(effect) });
            fWrapped->priv().addToKey(childContext, builder, gatherer, desiredCombination);
        builder->endBlock();
    }

    sk_sp<PrecompileShader> fWrapped;
    int fNumWrappedCombos;
    SkKnownRuntimeEffects::StableKey fStableKey;
};

sk_sp<PrecompileShader> PrecompileShadersPriv::LinearMorphology(sk_sp<PrecompileShader> wrapped) {
    return sk_make_sp<PrecompileMorphologyShader>(
            std::move(wrapped),
            SkKnownRuntimeEffects::StableKey::kLinearMorphology);
}

sk_sp<PrecompileShader> PrecompileShadersPriv::SparseMorphology(sk_sp<PrecompileShader> wrapped) {
    return sk_make_sp<PrecompileMorphologyShader>(
            std::move(wrapped),
            SkKnownRuntimeEffects::StableKey::kSparseMorphology);
}

//--------------------------------------------------------------------------------------------------
class PrecompileDisplacementShader final : public PrecompileShader {
public:
    PrecompileDisplacementShader(sk_sp<PrecompileShader> displacement,
                                 sk_sp<PrecompileShader> color)
            : fDisplacement(std::move(displacement))
            , fColor(std::move(color)) {
        fNumDisplacementCombos = fDisplacement->priv().numCombinations();
        fNumColorCombos = fColor->priv().numCombinations();
    }

private:
    int numChildCombinations() const override { return fNumDisplacementCombos * fNumColorCombos; }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < this->numChildCombinations());

        const int desiredDisplacementCombination = desiredCombination % fNumDisplacementCombos;
        const int desiredColorCombination = desiredCombination / fNumDisplacementCombos;
        SkASSERT(desiredColorCombination < fNumColorCombos);

        const SkRuntimeEffect* fEffect =
                GetKnownRuntimeEffect(SkKnownRuntimeEffects::StableKey::kDisplacement);

        KeyContextWithScope childContext(keyContext, KeyContext::Scope::kRuntimeEffect);

        RuntimeEffectBlock::BeginBlock(keyContext, builder, gatherer, { sk_ref_sp(fEffect) });
            fDisplacement->priv().addToKey(childContext, builder, gatherer,
                                           desiredDisplacementCombination);
            fColor->priv().addToKey(childContext, builder, gatherer,
                                    desiredColorCombination);
        builder->endBlock();
    }

    sk_sp<PrecompileShader> fDisplacement;
    int fNumDisplacementCombos;
    sk_sp<PrecompileShader> fColor;
    int fNumColorCombos;
};

//--------------------------------------------------------------------------------------------------
sk_sp<PrecompileShader> PrecompileShadersPriv::Displacement(sk_sp<PrecompileShader> displacement,
                                                            sk_sp<PrecompileShader> color) {
    return sk_make_sp<PrecompileDisplacementShader>(std::move(displacement), std::move(color));
}

//--------------------------------------------------------------------------------------------------
class PrecompileLightingShader final : public PrecompileShader {
public:
    PrecompileLightingShader(sk_sp<PrecompileShader> wrapped)
            : fWrapped(std::move(wrapped)) {
        fNumWrappedCombos = fWrapped->priv().numCombinations();
    }

private:
    int numChildCombinations() const override { return fNumWrappedCombos; }

    void addToKey(const KeyContext& keyContext,
                  PaintParamsKeyBuilder* builder,
                  PipelineDataGatherer* gatherer,
                  int desiredCombination) const override {
        SkASSERT(desiredCombination < fNumWrappedCombos);

        const SkRuntimeEffect* normalEffect =
                GetKnownRuntimeEffect(SkKnownRuntimeEffects::StableKey::kNormal);
        const SkRuntimeEffect* lightingEffect =
                GetKnownRuntimeEffect(SkKnownRuntimeEffects::StableKey::kLighting);

        KeyContextWithScope childContext(keyContext, KeyContext::Scope::kRuntimeEffect);

        RuntimeEffectBlock::BeginBlock(keyContext, builder, gatherer,
                                       { sk_ref_sp(lightingEffect) });
            RuntimeEffectBlock::BeginBlock(childContext, builder, gatherer,
                                           { sk_ref_sp(normalEffect) });
                fWrapped->priv().addToKey(childContext, builder, gatherer, desiredCombination);
            builder->endBlock();
        builder->endBlock();
    }

    sk_sp<PrecompileShader> fWrapped;
    int fNumWrappedCombos;
};

sk_sp<PrecompileShader> PrecompileShadersPriv::Lighting(sk_sp<PrecompileShader> wrapped) {
    return sk_make_sp<PrecompileLightingShader>(std::move(wrapped));
}

//--------------------------------------------------------------------------------------------------

} // namespace skgpu::graphite
