# libpng
function(xgd_build_png_library)
    set(INC_DIR ${XGD_DEPS_DIR}/png/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/png/src)
    xgd_add_library(
            png
            SRC_DIRS ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
    )
    if (WIN32 AND BUILD_SHARED_LIBS)
        target_compile_definitions(png PRIVATE PNG_BUILD_DLL)
    endif ()
    if (XGD_ARCH_X86)
        set(LIBPNG_INTEL_SOURCES
                intel/intel_init.c
                intel/filter_sse2_intrinsics.c)
        if (XGD_FLAG_SSE)
            target_compile_definitions(png PRIVATE PNG_INTEL_SSE_OPT=1)
        else ()
            target_compile_definitions(png PRIVATE PNG_INTEL_SSE_OPT=0)
        endif ()
    elseif (XGD_ARCH_ARM32 OR XGD_ARCH_ARM64)
        set(LIBPNG_ARM_SOURCES
                arm/arm_init.c
                arm/filter_neon.S
                arm/filter_neon_intrinsics.c
                arm/palette_neon_intrinsics.c)
        if (XGD_FLAG_NEON)
            target_compile_definitions(png PRIVATE PNG_ARM_NEON_OPT=2)
        else ()
            target_compile_definitions(png PRIVATE PNG_ARM_NEON_CHECK_SUPPORTED)
            # target_compile_definitions(png PRIVATE PNG_ARM_NEON_OPT=0)
        endif ()
    elseif (XGD_ARCH_POWER)
        set(LIBPNG_POWERPC_SOURCES
                powerpc/powerpc_init.c
                powerpc/filter_vsx_intrinsics.c)
        target_compile_definitions(png PRIVATE PNG_POWERPC_VSX_OPT=2)
        # target_compile_definitions(png PRIVATE PNG_POWERPC_VSX_OPT=0)
    elseif (XGD_ARCH_MIPS)
        set(LIBPNG_MIPS_SOURCES
                mips/mips_init.c
                mips/filter_msa_intrinsics.c)
        target_compile_definitions(png PRIVATE PNG_MIPS_MSA_OPT=2)
        # target_compile_definitions(png PRIVATE PNG_MIPS_MSA_OPT=0)
    endif ()

    foreach (SRC_FILE ${LIBPNG_ARM_SOURCES} ${LIBPNG_INTEL_SOURCES} ${LIBPNG_MIPS_SOURCES} ${LIBPNG_POWERPC_SOURCES})
        target_sources(png PRIVATE ${SRC_DIR}/${SRC_FILE})
    endforeach ()

    xgd_link_zlib(png PUBLIC)
endfunction()
