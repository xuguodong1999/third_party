# skia
set(ROOT_DIR ${XGD_THIRD_PARTY_DIR}/skia-src/skia)
set(INC_DIR ${ROOT_DIR}/include)
set(SRC_DIR ${ROOT_DIR}/src)

#############################
# This file contains lists of files and defines used in the legacy G3 build that is the G3 build
# that is not derived from our Bazel rules.

# All platform-independent sources and private headers.
set(ENCODE_SRCS
        src/encode/SkEncoder.cpp
        src/encode/SkICC.cpp)

set(ENCODE_JPEG_SRCS
        src/encode/SkJpegEncoderImpl.cpp
        src/encode/SkJPEGWriteUtility.cpp)

set(NO_ENCODE_JPEG_SRCS
        src/encode/SkJpegEncoder_none.cpp)

set(ENCODE_PNG_SRCS
        src/encode/SkPngEncoderBase.cpp
        src/encode/SkPngEncoderImpl.cpp)

set(NO_ENCODE_PNG_SRCS
        src/encode/SkPngEncoder_none.cpp)

set(ENCODE_WEBP_SRCS
        src/encode/SkWebpEncoderImpl.cpp)

set(NO_ENCODE_WEBP_SRCS
        src/encode/SkWebpEncoder_none.cpp)

set(CODEC_SRCS_LIMITED
        src/codec/SkAndroidCodec.cpp
        src/codec/SkAndroidCodecAdapter.cpp
        src/codec/SkBmpBaseCodec.cpp
        src/codec/SkBmpCodec.cpp
        src/codec/SkBmpMaskCodec.cpp
        src/codec/SkBmpRLECodec.cpp
        src/codec/SkBmpStandardCodec.cpp
        src/codec/SkCodec.cpp
        src/codec/SkCodecImageGenerator.cpp
        src/codec/SkColorPalette.cpp
        src/codec/SkExif.cpp
        src/codec/SkGainmapInfo.cpp
        src/codec/SkEncodedInfo.cpp
        src/codec/SkImageGenerator_FromEncoded.cpp
        src/codec/SkJpegCodec.cpp
        src/codec/SkJpegDecoderMgr.cpp
        src/codec/SkJpegMetadataDecoderImpl.cpp
        src/codec/SkJpegSourceMgr.cpp
        src/codec/SkJpegUtility.cpp
        src/codec/SkMaskSwizzler.cpp
        src/codec/SkParseEncodedOrigin.cpp
        src/codec/SkSampledCodec.cpp
        src/codec/SkSampler.cpp
        src/codec/SkSwizzler.cpp
        src/codec/SkTiffUtility.cpp
        src/codec/SkWbmpCodec.cpp
        src/codec/SkWuffsCodec.cpp)

set(CODEC_SRCS_ALL ${CODEC_SRCS_LIMITED}
        src/codec/SkIcoCodec.cpp
        src/codec/SkPngCodec.cpp
        src/codec/SkPngCodecBase.cpp
        src/codec/SkPngCompositeChunkReader.cpp
        src/codec/SkWebpCodec.cpp)

set(TEXTUAL_HDRS
        src/sksl/generated/sksl_compute.minified.sksl
        src/sksl/generated/sksl_compute.unoptimized.sksl
        src/sksl/generated/sksl_frag.minified.sksl
        src/sksl/generated/sksl_frag.unoptimized.sksl
        src/sksl/generated/sksl_gpu.minified.sksl
        src/sksl/generated/sksl_gpu.unoptimized.sksl
        src/sksl/generated/sksl_graphite_frag.minified.sksl
        src/sksl/generated/sksl_graphite_frag.unoptimized.sksl
        src/sksl/generated/sksl_graphite_vert.minified.sksl
        src/sksl/generated/sksl_graphite_vert.unoptimized.sksl
        src/sksl/generated/sksl_public.minified.sksl
        src/sksl/generated/sksl_public.unoptimized.sksl
        src/sksl/generated/sksl_rt_shader.minified.sksl
        src/sksl/generated/sksl_rt_shader.unoptimized.sksl
        src/sksl/generated/sksl_shared.minified.sksl
        src/sksl/generated/sksl_shared.unoptimized.sksl
        src/sksl/generated/sksl_vert.minified.sksl
        src/sksl/generated/sksl_vert.unoptimized.sksl
        # Included by GrGLMakeNativeInterface_android.cpp
        src/gpu/ganesh/gl/egl/GrGLMakeEGLInterface.cpp
        src/gpu/ganesh/gl/egl/GrGLMakeNativeInterface_egl.cpp)

set(base_gl_srcs
        src/gpu/ganesh/gl/GrGLAssembleGLESInterfaceAutogen.cpp
        src/gpu/ganesh/gl/GrGLAssembleGLInterfaceAutogen.cpp
        src/gpu/ganesh/gl/GrGLAssembleHelpers.cpp
        src/gpu/ganesh/gl/GrGLAssembleInterface.cpp
        src/gpu/ganesh/gl/GrGLAssembleWebGLInterfaceAutogen.cpp
        src/gpu/ganesh/gl/GrGLAttachment.cpp
        src/gpu/ganesh/gl/GrGLBackendSurface.cpp
        src/gpu/ganesh/gl/GrGLBuffer.cpp
        src/gpu/ganesh/gl/GrGLCaps.cpp
        src/gpu/ganesh/gl/GrGLContext.cpp
        src/gpu/ganesh/gl/GrGLDirectContext.cpp
        src/gpu/ganesh/gl/GrGLExtensions.cpp
        src/gpu/ganesh/gl/GrGLFinishCallbacks.cpp
        src/gpu/ganesh/gl/GrGLGLSL.cpp
        src/gpu/ganesh/gl/GrGLGpu.cpp
        src/gpu/ganesh/gl/GrGLGpuProgramCache.cpp
        src/gpu/ganesh/gl/GrGLInterfaceAutogen.cpp
        src/gpu/ganesh/gl/GrGLOpsRenderPass.cpp
        src/gpu/ganesh/gl/GrGLProgram.cpp
        src/gpu/ganesh/gl/GrGLProgramDataManager.cpp
        src/gpu/ganesh/gl/GrGLRenderTarget.cpp
        src/gpu/ganesh/gl/GrGLSemaphore.cpp
        src/gpu/ganesh/gl/GrGLTexture.cpp
        src/gpu/ganesh/gl/GrGLTextureRenderTarget.cpp
        src/gpu/ganesh/gl/GrGLTypesPriv.cpp
        src/gpu/ganesh/gl/GrGLUniformHandler.cpp
        src/gpu/ganesh/gl/GrGLUtil.cpp
        src/gpu/ganesh/gl/GrGLVertexArray.cpp
        src/gpu/ganesh/gl/builders/GrGLProgramBuilder.cpp
        src/gpu/ganesh/gl/builders/GrGLShaderStringBuilder.cpp)

set(GL_SRCS_UNIX ${base_gl_srcs}
        src/gpu/ganesh/gl/GrGLMakeNativeInterface_none.cpp)

set(GL_SRCS_UNIX_EGL ${base_gl_srcs}
        src/gpu/ganesh/gl/egl/GrGLMakeEGLInterface.cpp
        src/gpu/ganesh/gl/egl/GrGLMakeNativeInterface_egl.cpp)

set(PORTS_SRCS_WIN
        src/ports/SkFontMgr_win_dw.cpp
        src/ports/SkScalerContext_win_dw.cpp
        src/ports/SkTypeface_win_dw.cpp
        src/ports/SkGlobalInitialization_default.cpp
        src/ports/SkOSFile_win.cpp
        src/ports/SkOSFile_stdio.cpp
        src/ports/SkDebug_win.cpp
        src/ports/SkMemory_malloc.cpp)
set(PORTS_SRCS_UNIX
        src/ports/SkDebug_stdio.cpp
        src/ports/SkFontHost_FreeType_common.cpp
        src/ports/SkFontHost_FreeType.cpp
        src/ports/SkFontMgr_custom.cpp
        src/ports/SkFontMgr_custom_directory.cpp
        src/ports/SkFontMgr_custom_embedded.cpp
        src/ports/SkFontMgr_custom_empty.cpp
        src/ports/SkGlobalInitialization_default.cpp
        src/ports/SkMemory_malloc.cpp
        src/ports/SkOSFile_posix.cpp
        src/ports/SkOSFile_stdio.cpp
)
if (XGD_USE_FONTCONFIG)
    list(APPEND PORTS_SRCS_UNIX
            src/ports/SkFontMgr_fontconfig.cpp)
endif ()

set(GL_SRCS_ANDROID ${base_gl_srcs}
        src/gpu/ganesh/gl/android/GrGLMakeNativeInterface_android.cpp)

set(PORTS_SRCS_ANDROID
        src/ports/SkDebug_android.cpp
        src/ports/SkFontHost_FreeType_common.cpp
        src/ports/SkFontHost_FreeType.cpp
        src/ports/SkFontMgr_android.cpp
        src/ports/SkFontMgr_android_factory.cpp
        src/ports/SkFontMgr_android_parser.cpp
        src/ports/SkFontMgr_custom.cpp
        src/ports/SkFontMgr_custom_directory.cpp
        src/ports/SkFontMgr_custom_embedded.cpp
        src/ports/SkFontMgr_custom_empty.cpp
        src/ports/SkGlobalInitialization_default.cpp
        src/ports/SkMemory_malloc.cpp
        src/ports/SkOSFile_posix.cpp
        src/ports/SkOSFile_stdio.cpp)

set(PORTS_SRCS_ANDROID_NO_FONT
        src/gpu/android/AHardwareBufferUtils.cpp
        src/gpu/graphite/surface/Surface_AndroidFactories.cpp
        src/ports/SkDebug_android.cpp
        src/ports/SkGlobalInitialization_default.cpp
        src/ports/SkMemory_malloc.cpp
        src/ports/SkOSFile_posix.cpp
        src/ports/SkOSFile_stdio.cpp)

set(GL_SRCS_IOS ${base_gl_srcs}
        src/gpu/ganesh/gl/iOS/GrGLMakeNativeInterface_iOS.cpp)

set(PORTS_SRCS_IOS
        src/ports/SkDebug_stdio.cpp
        src/ports/SkFontMgr_mac_ct.cpp
        src/ports/SkGlobalInitialization_default.cpp
        src/ports/SkImageGeneratorCG.cpp
        src/ports/SkMemory_malloc.cpp
        src/ports/SkOSFile_posix.cpp
        src/ports/SkOSFile_stdio.cpp
        src/ports/SkScalerContext_mac_ct.cpp
        src/ports/SkTypeface_mac_ct.cpp
        src/utils/mac/SkCreateCGImageRef.cpp
        src/utils/mac/SkCTFontCreateExactCopy.cpp
        src/utils/mac/SkCTFont.cpp)

set(PORTS_SRCS_FUCHSIA
        src/ports/SkDebug_stdio.cpp
        src/ports/SkFontHost_FreeType_common.cpp
        src/ports/SkFontHost_FreeType.cpp
        src/ports/SkFontMgr_custom.cpp
        src/ports/SkFontMgr_fuchsia.cpp
        src/ports/SkGlobalInitialization_default.cpp
        src/ports/SkMemory_malloc.cpp
        src/ports/SkOSFile_posix.cpp
        src/ports/SkOSFile_stdio.cpp)

set(GL_SRCS_MACOS ${base_gl_srcs}
        src/gpu/ganesh/gl/mac/GrGLMakeNativeInterface_mac.cpp)

set(PORTS_SRCS_MACOS ${PORTS_SRCS_IOS})

set(PORTS_SRCS_WASM
        src/ports/SkDebug_stdio.cpp
        src/ports/SkFontHost_FreeType_common.cpp
        src/ports/SkFontHost_FreeType.cpp
        src/ports/SkFontMgr_custom.cpp
        src/ports/SkFontMgr_custom_embedded.cpp
        src/ports/SkGlobalInitialization_default.cpp
        src/ports/SkMemory_malloc.cpp
        src/ports/SkOSFile_posix.cpp
        src/ports/SkOSFile_stdio.cpp)
set(GL_SRCS_WASM ${GL_SRCS_UNIX_EGL})

set(MTL_SRCS
        src/gpu/ganesh/mtl/GrMtlAttachment.mm
        src/gpu/ganesh/mtl/GrMtlBuffer.mm
        src/gpu/ganesh/mtl/GrMtlCaps.mm
        src/gpu/ganesh/mtl/GrMtlCommandBuffer.mm
        src/gpu/ganesh/mtl/GrMtlDepthStencil.mm
        src/gpu/ganesh/mtl/GrMtlFramebuffer.mm
        src/gpu/ganesh/mtl/GrMtlGpu.mm
        src/gpu/ganesh/mtl/GrMtlOpsRenderPass.mm
        src/gpu/ganesh/mtl/GrMtlPipelineState.mm
        src/gpu/ganesh/mtl/GrMtlPipelineStateBuilder.mm
        src/gpu/ganesh/mtl/GrMtlPipelineStateDataManager.mm
        src/gpu/ganesh/mtl/GrMtlRenderTarget.mm
        src/gpu/ganesh/mtl/GrMtlResourceProvider.mm
        src/gpu/ganesh/mtl/GrMtlSampler.mm
        src/gpu/ganesh/mtl/GrMtlSemaphore.mm
        src/gpu/ganesh/mtl/GrMtlTexture.mm
        src/gpu/ganesh/mtl/GrMtlTextureRenderTarget.mm
        src/gpu/ganesh/mtl/GrMtlTrampoline.mm
        src/gpu/ganesh/mtl/GrMtlTypesPriv.mm
        src/gpu/ganesh/mtl/GrMtlUniformHandler.mm
        src/gpu/ganesh/mtl/GrMtlUtil.mm
        src/gpu/ganesh/mtl/GrMtlVaryingHandler.mm
        src/gpu/ganesh/surface/SkSurface_GaneshMtl.mm
        src/gpu/mtl/MtlMemoryAllocatorImpl.mm
        src/gpu/mtl/MtlUtils.mm)

set(VULKAN_SRCS
        src/gpu/ganesh/vk/GrVkBackendSurface.cpp
        src/gpu/ganesh/vk/GrVkBuffer.cpp
        src/gpu/ganesh/vk/GrVkCaps.cpp
        src/gpu/ganesh/vk/GrVkCommandBuffer.cpp
        src/gpu/ganesh/vk/GrVkCommandPool.cpp
        src/gpu/ganesh/vk/GrVkDescriptorPool.cpp
        src/gpu/ganesh/vk/GrVkDescriptorSet.cpp
        src/gpu/ganesh/vk/GrVkDescriptorSetManager.cpp
        src/gpu/ganesh/vk/GrVkDirectContext.cpp
        src/gpu/ganesh/vk/GrVkFramebuffer.cpp
        src/gpu/ganesh/vk/GrVkGpu.cpp
        src/gpu/ganesh/vk/GrVkImage.cpp
        src/gpu/ganesh/vk/GrVkImageView.cpp
        src/gpu/ganesh/vk/GrVkMSAALoadManager.cpp
        src/gpu/ganesh/vk/GrVkOpsRenderPass.cpp
        src/gpu/ganesh/vk/GrVkPipeline.cpp
        src/gpu/ganesh/vk/GrVkPipelineStateBuilder.cpp
        src/gpu/ganesh/vk/GrVkPipelineStateCache.cpp
        src/gpu/ganesh/vk/GrVkPipelineState.cpp
        src/gpu/ganesh/vk/GrVkPipelineStateDataManager.cpp
        src/gpu/ganesh/vk/GrVkRenderPass.cpp
        src/gpu/ganesh/vk/GrVkRenderTarget.cpp
        src/gpu/ganesh/vk/GrVkResourceProvider.cpp
        src/gpu/ganesh/vk/GrVkSampler.cpp
        src/gpu/ganesh/vk/GrVkSamplerYcbcrConversion.cpp
        src/gpu/ganesh/vk/GrVkSemaphore.cpp
        src/gpu/ganesh/vk/GrVkTexture.cpp
        src/gpu/ganesh/vk/GrVkTextureRenderTarget.cpp
        src/gpu/ganesh/vk/GrVkTypesPriv.cpp
        src/gpu/ganesh/vk/GrVkUniformHandler.cpp
        src/gpu/ganesh/vk/GrVkUtil.cpp
        src/gpu/ganesh/vk/GrVkVaryingHandler.cpp
        src/gpu/vk/VulkanExtensions.cpp
        src/gpu/vk/VulkanInterface.cpp
        src/gpu/vk/VulkanMemory.cpp)


#############################
set(SKIA_SRC_FILES
        src/codec/SkPixmapUtils.cpp
        ${CODEC_SRCS_ALL}
        ${ENCODE_SRCS}
        ${ENCODE_PNG_SRCS}
        ${NO_ENCODE_JPEG_SRCS}
        ${NO_ENCODE_WEBP_SRCS})
if (XGD_USE_VULKAN)
    list(APPEND SKIA_SRC_FILES ${VULKAN_SRCS})
endif ()
if (WIN32)
    list(APPEND SKIA_SRC_FILES ${PORTS_SRCS_WIN})
elseif (ANDROID)
    list(APPEND SKIA_SRC_FILES
            # ${PORTS_SRCS_ANDROID} # no expat.h found
            ${PORTS_SRCS_ANDROID_NO_FONT})
elseif (IOS)
    list(APPEND SKIA_SRC_FILES ${PORTS_SRCS_IOS} ${GL_SRCS_IOS})
elseif (APPLE)
    list(APPEND SKIA_SRC_FILES ${PORTS_SRCS_MACOS} ${GL_SRCS_MACOS})
elseif (EMSCRIPTEN)
    list(APPEND SKIA_SRC_FILES ${PORTS_SRCS_WASM} ${GL_SRCS_WASM})
elseif (UNIX)
    if (XGD_USE_FONTCONFIG)
        find_package(Fontconfig REQUIRED)
    endif ()
    list(APPEND SKIA_SRC_FILES ${PORTS_SRCS_UNIX} ${GL_SRCS_UNIX})
endif ()

set(SKIA_SRC_DIRS
        ${SRC_DIR}/base
        ${SRC_DIR}/core
        ${SRC_DIR}/effects
        ${SRC_DIR}/effects/colorfilters
        ${SRC_DIR}/effects/imagefilters
        ${SRC_DIR}/fonts
        ${SRC_DIR}/gpu
        ${SRC_DIR}/gpu/ganesh
        ${SRC_DIR}/gpu/ganesh/effects
        ${SRC_DIR}/gpu/ganesh/geometry
        ${SRC_DIR}/gpu/ganesh/glsl
        ${SRC_DIR}/gpu/ganesh/gradients
        ${SRC_DIR}/gpu/ganesh/image
        ${SRC_DIR}/gpu/ganesh/mock
        ${SRC_DIR}/gpu/ganesh/ops
        ${SRC_DIR}/gpu/ganesh/surface
        ${SRC_DIR}/gpu/ganesh/tessellate
        ${SRC_DIR}/gpu/ganesh/text
        ${SRC_DIR}/gpu/tessellate
        ${SRC_DIR}/image
        ${SRC_DIR}/opts
        ${SRC_DIR}/pathops
#        ${SRC_DIR}/pdf  # disable skia pdf due to its dependency on jpeg decoder
        ${SRC_DIR}/sfnt
        ${SRC_DIR}/shaders
        ${SRC_DIR}/shaders/gradients
        ${SRC_DIR}/sksl
        ${SRC_DIR}/sksl/analysis
        ${SRC_DIR}/sksl/codegen
        ${SRC_DIR}/sksl/ir
        ${SRC_DIR}/sksl/tracing
        ${SRC_DIR}/sksl/transform
        ${SRC_DIR}/text
        ${SRC_DIR}/text/gpu
        ${SRC_DIR}/utils
#        ${SRC_DIR}/xps
)
if (WIN32)
    list(APPEND SKIA_SRC_DIRS ${SRC_DIR}/utils/win)
elseif (APPLE)
    list(APPEND SKIA_SRC_DIRS ${SRC_DIR}/utils/apple)
endif ()

set(SKIA_SRC_FILE_PATHS)
foreach (SKIA_SRC_FILE ${SKIA_SRC_FILES})
    list(APPEND SKIA_SRC_FILE_PATHS ${ROOT_DIR}/${SKIA_SRC_FILE})
endforeach ()

xgd_add_library(skcms STATIC SRC_FILES
        ${ROOT_DIR}/modules/skcms/skcms.cc
        ${ROOT_DIR}/modules/skcms/src/skcms_TransformBaseline.cc
        ${ROOT_DIR}/modules/skcms/src/skcms_TransformHsw.cc
        ${ROOT_DIR}/modules/skcms/src/skcms_TransformSkx.cc
)

xgd_add_library(skia
        SRC_FILES
        ${SKIA_SRC_FILE_PATHS}
        EXCLUDE_SRC_FILES
        ${SRC_DIR}/pdf/SkJpegInfo_libjpegturbo.cpp
        ${SRC_DIR}/pdf/SkDocument_PDF_None.cpp
        ${SRC_DIR}/gpu/ganesh/surface/SkSurface_GaneshMtl.mm
        ${SRC_DIR}/codec/SkWuffsCodec.cpp
        ${SRC_DIR}/codec/SkWebpCodec.cpp
        ${SRC_DIR}/codec/SkJpegCodec.cpp
        ${SRC_DIR}/codec/SkJpegDecoderMgr.cpp
        ${SRC_DIR}/codec/SkJpegMultiPicture.cpp
        ${SRC_DIR}/codec/SkJpegSegmentScan.cpp
        ${SRC_DIR}/codec/SkJpegSourceMgr.cpp
        ${SRC_DIR}/codec/SkJpegUtility.cpp
        ${SRC_DIR}/codec/SkJpegxlCodec.cpp
        ${SRC_DIR}/codec/SkJpegXmp.cpp
        ${SRC_DIR}/utils/win/SkWGL_win.cpp
        ${SRC_DIR}/utils/SkGetExecutablePath_win.cpp
        ${SRC_DIR}/utils/SkGetExecutablePath_mac.cpp
        ${SRC_DIR}/utils/SkGetExecutablePath_linux.cpp
        ${SRC_DIR}/sksl/codegen/SkSLWGSLValidator.cpp
        ${SRC_DIR}/sksl/codegen/SkSLHLSLCodeGenerator.cpp
        ${SRC_DIR}/sksl/codegen/SkSLSPIRVValidator.cpp
        ${SRC_DIR}/sksl/codegen/SkSLSPIRVtoHLSL.cpp
        ${SRC_DIR}/sksl/SkSLModuleDataFile.cpp
        SRC_DIRS
        ${SKIA_SRC_DIRS}
        INCLUDE_DIRS
        ${ROOT_DIR}
        ${INC_DIR}/core
        ${INC_DIR}/ports
        ${INC_DIR}/utils
        ${INC_DIR}/effects
        ${INC_DIR}/encode
        ${INC_DIR}/images)
if (BUILD_SHARED_LIBS)
    target_compile_definitions(skia PUBLIC SKIA_DLL PRIVATE SKIA_IMPLEMENTATION)
endif ()
if (XGD_USE_VULKAN)
    xgd_link_vulkan(skia)
endif ()
if (APPLE)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation REQUIRED)
    find_library(CORETEXT_LIBRARY CoreText REQUIRED)
    find_library(COREGRAPHICS_LIBRARY CoreGraphics REQUIRED)
    find_library(IMAGEIO_LIBRARY ImageIO REQUIRED)
    target_link_libraries(
            skia PRIVATE
            ${COREFOUNDATION_LIBRARY}
            ${CORETEXT_LIBRARY}
            ${COREGRAPHICS_LIBRARY}
            ${IMAGEIO_LIBRARY}
    )
    target_compile_definitions(skia PUBLIC SK_FONTMGR_CORETEXT_AVAILABLE)
endif ()

if (WIN32)
    target_compile_definitions(skia PUBLIC SK_FONTMGR_DIRECTWRITE_AVAILABLE)
endif ()

target_compile_definitions(skia PRIVATE
        SK_CODEC_DECODES_PNG
        # Our legacy G3 rule *always* has the ganesh backend enabled.
        SK_GANESH
        # Chrome DEFINES.
        SK_USE_FREETYPE_EMBOLDEN
        # Turn on a few Google3-specific build fixes.
        # SK_BUILD_FOR_GOOGLE3
        # Required for building dm.
        GR_TEST_UTILS
        # Should remove after we update golden images
        SK_WEBP_ENCODER_USE_DEFAULT_METHOD
        # Experiment to diagnose image diffs in Google3
        SK_DISABLE_LOWP_RASTER_PIPELINE)
xgd_link_libraries(skia PRIVATE skcms png zlib freetype)
target_link_libraries(skia PRIVATE $<$<BOOL:${ANDROID}>:log>)
if (XGD_USE_FONTCONFIG AND UNIX AND NOT ANDROID AND NOT IOS AND NOT EMSCRIPTEN AND NOT APPLE)
    xgd_link_libraries(skia PRIVATE Fontconfig::Fontconfig)
    target_compile_definitions(skia PUBLIC SK_FONTMGR_FONTCONFIG_AVAILABLE)
endif ()

function(xgd_build_skia_module_libs MODULE_NAME)
    target_sources(skia PRIVATE ${ROOT_DIR}/modules/${MODULE_NAME}/src)
    target_include_directories(
            skia
            PUBLIC
            ${ROOT_DIR}
            ${ROOT_DIR}/modules/${MODULE_NAME}/include
    )
    add_library(skia_${MODULE_NAME} ALIAS skia)
    #    xgd_add_library(skia_${MODULE_NAME} STATIC
    #            SRC_DIRS
    #            ${ROOT_DIR}/modules/${MODULE_NAME}/src
    #            INCLUDE_DIRS
    #            ${ROOT_DIR}
    #            ${ROOT_DIR}/modules/${MODULE_NAME}/include)
    #    xgd_link_libraries(skia_${MODULE_NAME} PRIVATE skia)
    #    if (BUILD_SHARED_LIBS)
    #        target_compile_definitions(
    #                skia_${MODULE_NAME} PRIVATE SKIA_IMPLEMENTATION)
    #    endif ()
endfunction()

xgd_build_skia_module_libs(sksg)
#xgd_build_skia_module_libs(skparagraph)
xgd_build_skia_module_libs(skresources)
#xgd_build_skia_module_libs(skottie)
#xgd_build_skia_module_libs(skottie_ios)
xgd_build_skia_module_libs(svg)
#xgd_build_skia_module_libs(xml)
