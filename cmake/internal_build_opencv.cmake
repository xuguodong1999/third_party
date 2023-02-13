# opencv
function(xgd_build_opencv_library)
    set(CPU_DISPATCH_FINAL "")
    if (XGD_FLAG_SSE)
        list(APPEND CPU_DISPATCH_FINAL SSE2 SSE4_1)
    endif ()
    if (XGD_FLAG_AVX)
        list(APPEND CPU_DISPATCH_FINAL AVX)
    endif ()
    if (XGD_FLAG_AVX2)
        list(APPEND CPU_DISPATCH_FINAL AVX2)
    endif ()
    if (XGD_FLAG_NEON)
        list(APPEND CPU_DISPATCH_FINAL NEON_DOTPROD)
    endif ()
    set(CPU_BASELINE_FINAL ${CPU_DISPATCH_FINAL})

    set(OCV_ROOT ${XGD_DEPS_DIR}/cpp/opencv-src/opencv)
    set(OCV_MODULE_DIR ${OCV_ROOT}/modules)
    set(OCV_GENERATED_INC_DIR ${XGD_GENERATED_DIR}/opencv/include)
    set(OCV_GENERATED_SRC_DIR ${XGD_GENERATED_DIR}/opencv/src)

    set(OPENCV_MODULE_DEFINITIONS_CONFIGMAKE "")
    foreach (m opencv_core opencv_imgproc)
        string(TOUPPER "${m}" m)
        set(OPENCV_MODULE_DEFINITIONS_CONFIGMAKE "${OPENCV_MODULE_DEFINITIONS_CONFIGMAKE}#define HAVE_${m}\n")
    endforeach ()
    set(OPENCV_MODULE_DEFINITIONS_CONFIGMAKE "${OPENCV_MODULE_DEFINITIONS_CONFIGMAKE}\n")
    configure_file(${OCV_ROOT}/cmake/templates/opencv_modules.hpp.in
            ${OCV_GENERATED_INC_DIR}/opencv2/opencv_modules.hpp)

    set(HAVE_PNG ON)
    set(HAVE_EIGEN ON)
    configure_file(${OCV_ROOT}/cmake/templates/cvconfig.h.in
            ${OCV_GENERATED_INC_DIR}/cvconfig.h)
    configure_file(${OCV_ROOT}/cmake/templates/cvconfig.h.in
            ${OCV_GENERATED_INC_DIR}/opencv2/cvconfig.h)

    set(OPENCV_CPU_DISPATCH_DEFINITIONS_CONFIGMAKE "")
    set(OPENCV_CPU_BASELINE_DEFINITIONS_CONFIGMAKE "")

    foreach (OPT ${CPU_BASELINE_FINAL})
        set(OPENCV_CPU_BASELINE_DEFINITIONS_CONFIGMAKE "${OPENCV_CPU_BASELINE_DEFINITIONS_CONFIGMAKE}
#define CV_CPU_COMPILE_${OPT} 1
#define CV_CPU_BASELINE_COMPILE_${OPT} 1
")
    endforeach ()


    set(OPENCV_CPU_BASELINE_DEFINITIONS_CONFIGMAKE "${OPENCV_CPU_BASELINE_DEFINITIONS_CONFIGMAKE}
#define CV_CPU_BASELINE_FEATURES 0 \\")
    foreach (OPT ${CPU_BASELINE_FINAL})
        if (NOT DEFINED CPU_${OPT}_FEATURE_ALIAS OR NOT "x${CPU_${OPT}_FEATURE_ALIAS}" STREQUAL "x")
            set(OPENCV_CPU_BASELINE_DEFINITIONS_CONFIGMAKE "${OPENCV_CPU_BASELINE_DEFINITIONS_CONFIGMAKE}
    , CV_CPU_${OPT} \\")
        endif ()
    endforeach ()
    set(OPENCV_CPU_BASELINE_DEFINITIONS_CONFIGMAKE "${OPENCV_CPU_BASELINE_DEFINITIONS_CONFIGMAKE}\n")

    set(__dispatch_modes "")
    foreach (OPT ${CPU_DISPATCH_FINAL})
        list(APPEND __dispatch_modes ${CPU_DISPATCH_${OPT}_FORCE} ${OPT})
    endforeach ()
    list(REMOVE_DUPLICATES __dispatch_modes)
    foreach (OPT ${__dispatch_modes})
        set(OPENCV_CPU_DISPATCH_DEFINITIONS_CONFIGMAKE "${OPENCV_CPU_DISPATCH_DEFINITIONS_CONFIGMAKE}
#define CV_CPU_DISPATCH_COMPILE_${OPT} 1")
    endforeach ()

    set(OPENCV_CPU_DISPATCH_DEFINITIONS_CONFIGMAKE "${OPENCV_CPU_DISPATCH_DEFINITIONS_CONFIGMAKE}
\n\n#define CV_CPU_DISPATCH_FEATURES 0 \\")
    foreach (OPT ${__dispatch_modes})
        if (NOT DEFINED CPU_${OPT}_FEATURE_ALIAS OR NOT "x${CPU_${OPT}_FEATURE_ALIAS}" STREQUAL "x")
            set(OPENCV_CPU_DISPATCH_DEFINITIONS_CONFIGMAKE "${OPENCV_CPU_DISPATCH_DEFINITIONS_CONFIGMAKE}
    , CV_CPU_${OPT} \\")
        endif ()
    endforeach ()
    set(OPENCV_CPU_DISPATCH_DEFINITIONS_CONFIGMAKE "${OPENCV_CPU_DISPATCH_DEFINITIONS_CONFIGMAKE}\n")

    configure_file(${OCV_ROOT}/cmake/templates/cv_cpu_config.h.in
            ${OCV_GENERATED_INC_DIR}/cv_cpu_config.h)

    configure_file(${OCV_ROOT}/cmake/templates/custom_hal.hpp.in
            ${OCV_GENERATED_INC_DIR}/custom_hal.hpp @ONLY)
    configure_file(${XGD_DEPS_DIR}/cmake/opencv_data_config.hpp.in
            ${OCV_GENERATED_SRC_DIR}/opencv_data_config.hpp @ONLY)

    # reference: opencv/cmake/OpenCVCompilerOptimizations.cmake
    macro(__ocv_add_dispatched_file filename target_src_var src_directory dst_directory precomp_hpp optimizations_var)
        set(__codestr "
            #include \"${src_directory}/${precomp_hpp}\"
            #include \"${src_directory}/${filename}.simd.hpp\"")

        set(__declarations_str "#define CV_CPU_SIMD_FILENAME \"${src_directory}/${filename}.simd.hpp\"")
        set(__dispatch_modes "BASELINE")

        set(__optimizations "${${optimizations_var}}")
#        set(__optimizations "")
        foreach (OPT ${__optimizations})
            string(TOLOWER "${OPT}" OPT_LOWER)
            set(__file "${OCV_GENERATED_SRC_DIR}/${OCV_COMPONENT}/${dst_directory}${filename}.${OPT_LOWER}.cpp")
            if (EXISTS "${__file}")
                file(READ "${__file}" __content)
            else ()
                set(__content "")
            endif ()
            if (__content STREQUAL __codestr)
                # message(STATUS "${__file} contains up-to-date content")
            else ()
                file(WRITE "${__file}" "${__codestr}")
            endif ()

            if (";${CPU_DISPATCH_FINAL};" MATCHES "${OPT}" OR __CPU_DISPATCH_INCLUDE_ALL)
                if (EXISTS "${src_directory}/${filename}.${OPT_LOWER}.cpp")
                    message(STATUS "Using overridden ${OPT} source: ${src_directory}/${filename}.${OPT_LOWER}.cpp")
                else ()
                    list(APPEND ${target_src_var} "${__file}")
                    xgd_mark_generated("${__file}")
                endif ()
                set(__declarations_str "${__declarations_str}
                #define CV_CPU_DISPATCH_MODE ${OPT}
                #include \"opencv2/core/private/cv_cpu_include_simd_declarations.hpp\"")
                set(__dispatch_modes "${OPT}, ${__dispatch_modes}")
            endif ()
        endforeach ()

        set(__declarations_str "${__declarations_str}
            #define CV_CPU_DISPATCH_MODES_ALL ${__dispatch_modes}
            #undef CV_CPU_SIMD_FILENAME")

        set(__file "${OCV_GENERATED_SRC_DIR}/${OCV_COMPONENT}/${dst_directory}${filename}.simd_declarations.hpp")
        if (EXISTS "${__file}")
            file(READ "${__file}" __content)
        endif ()
        if (__content STREQUAL __declarations_str)
            # message(STATUS "${__file} contains up-to-date content")
        else ()
            file(WRITE "${__file}" "${__declarations_str}")
        endif ()
    endmacro()

    macro(ocv_add_dispatched_file filename)
        set(__optimizations "${ARGN}")
        __ocv_add_dispatched_file(
                "${filename}" "OPENCV_MODULE_${the_module}_SOURCES_DISPATCHED"
                "${OCV_MODULE_DIR}/${OCV_COMPONENT}/src" "" "precomp.hpp" __optimizations
        )
    endmacro()

    function(xgd_internal_build_opencv OCV_COMPONENT)
        set(OCV_COMPONENT_DIR ${OCV_MODULE_DIR}/${OCV_COMPONENT})
        if (NOT EXISTS ${OCV_COMPONENT_DIR})
            message(FATAL_ERROR "${OCV_COMPONENT_DIR} not exist for ${OCV_COMPONENT}")
        endif ()
        cmake_parse_arguments(param "" "" "SRC_FILES;SRC_DIRS" ${ARGN})
        set(OCV_COMPONENT_INC_DIR ${OCV_COMPONENT_DIR}/include)
        set(OCV_COMPONENT_SRC_DIR ${OCV_COMPONENT_DIR}/src)
        set(OCV_COMPONENT_GEN_DIR ${OCV_GENERATED_SRC_DIR}/${OCV_COMPONENT})

        file(GLOB cl_kernels ${OCV_COMPONENT_SRC_DIR}/opencl/*.cl)
        if (cl_kernels)
            set(OCL_NAME opencl_kernels_${OCV_COMPONENT})
            set(OUTPUT_SRC ${OCV_COMPONENT_GEN_DIR}/${OCL_NAME}.cpp)
            add_custom_command(
                    OUTPUT ${OUTPUT_SRC}
                    COMMAND
                    ${CMAKE_COMMAND}
                    "-DMODULE_NAME=${OCV_COMPONENT}"
                    "-DCL_DIR=${OCV_COMPONENT_SRC_DIR}/opencl"
                    "-DOUTPUT=${OUTPUT_SRC}"
                    -P
                    "${OCV_ROOT}/cmake/cl2cpp.cmake"
                    DEPENDS ${cl_kernels} "${OCV_ROOT}/cmake/cl2cpp.cmake"
                    COMMENT "Processing OpenCL kernels (${OCV_COMPONENT})"
            )
            xgd_mark_generated(${OUTPUT_SRC} ${OCV_GENERATED_SRC_DIR}/${OCV_COMPONENT}/${OCL_NAME}.hpp)
        endif ()

        xgd_add_library(
                opencv_${OCV_COMPONENT}
                SRC_DIRS
                ${param_SRC_DIRS}
                ${OCV_COMPONENT_SRC_DIR}

                SRC_FILES
                ${OUTPUT_SRC}

                INCLUDE_DIRS
                ${OCV_COMPONENT_INC_DIR}
                ${OCV_GENERATED_INC_DIR}
                ${OCV_ROOT}/include
                PRIVATE_INCLUDE_DIRS
                ${OCV_GENERATED_SRC_DIR}
                ${OCV_COMPONENT_GEN_DIR}
                EXCLUDE_REGEXES
                "^(.*)\\.avx(.*)\\.cpp"
                "^(.*)\\.sse(.*)\\.cpp"
                "^(.*)\\.lasx(.*)\\.cpp"
        )
        xgd_use_header(opencv_${OCV_COMPONENT} PRIVATE eigen)
        xgd_link_png(opencv_${OCV_COMPONENT})
        xgd_link_zlib(opencv_${OCV_COMPONENT})
        target_compile_definitions(opencv_${OCV_COMPONENT} PRIVATE __OPENCV_BUILD CVAPI_EXPORTS)

        if (NOT TARGET opencv_all)
            add_custom_target(opencv_all)
        endif ()
        add_dependencies(opencv_all opencv_${OCV_COMPONENT})
    endfunction()

    function(xgd_build_opencv_core)
        set(OCV_COMPONENT core)
        set(the_module opencv_${OCV_COMPONENT})
        ocv_add_dispatched_file(mathfuncs_core SSE2 AVX AVX2)
        ocv_add_dispatched_file(stat SSE4_2 AVX2)
        ocv_add_dispatched_file(arithm SSE2 SSE4_1 AVX2 VSX3)
        ocv_add_dispatched_file(convert SSE2 AVX2 VSX3)
        ocv_add_dispatched_file(convert_scale SSE2 AVX2)
        ocv_add_dispatched_file(count_non_zero SSE2 AVX2)
        ocv_add_dispatched_file(matmul SSE2 SSE4_1 AVX2 AVX512_SKX NEON_DOTPROD)
        ocv_add_dispatched_file(mean SSE2 AVX2)
        ocv_add_dispatched_file(merge SSE2 AVX2)
        ocv_add_dispatched_file(split SSE2 AVX2)
        ocv_add_dispatched_file(sum SSE2 AVX2)

        set(OPENCV_BUILD_INFO_STR "\"Build from ${PROJECT_NAME}\"")
        set(OPENCV_BUILD_INFO_FILE "${OCV_GENERATED_SRC_DIR}/version_string.inc")
        if (EXISTS "${OPENCV_BUILD_INFO_FILE}")
            file(READ "${OPENCV_BUILD_INFO_FILE}" __content)
        else ()
            set(__content "")
        endif ()
        if ("${__content}" STREQUAL "${OPENCV_BUILD_INFO_STR}")
            # message(STATUS "${OPENCV_BUILD_INFO_FILE} contains the same content")
        else ()
            file(WRITE "${OPENCV_BUILD_INFO_FILE}" "${OPENCV_BUILD_INFO_STR}")
        endif ()

        xgd_internal_build_opencv(
                core
                SRC_DIRS
                ${OCV_MODULE_DIR}/core/src/utils
                ${OCV_MODULE_DIR}/core/src/parallel

                SRC_FILES
                ${OPENCV_MODULE_${the_module}_SOURCES_DISPATCHED}
        )
    endfunction()
    xgd_build_opencv_core()
    function(xgd_build_opencv_imgproc)
        set(OCV_COMPONENT imgproc)
        set(the_module opencv_${OCV_COMPONENT})
        ocv_add_dispatched_file(accum SSE4_1 AVX AVX2)
        ocv_add_dispatched_file(bilateral_filter SSE2 AVX2)
        ocv_add_dispatched_file(box_filter SSE2 SSE4_1 AVX2)
        ocv_add_dispatched_file(filter SSE2 SSE4_1 AVX2)
        ocv_add_dispatched_file(color_hsv SSE2 SSE4_1 AVX2)
        ocv_add_dispatched_file(color_rgb SSE2 SSE4_1 AVX2)
        ocv_add_dispatched_file(color_yuv SSE2 SSE4_1 AVX2)
        ocv_add_dispatched_file(median_blur SSE2 SSE4_1 AVX2)
        ocv_add_dispatched_file(morph SSE2 SSE4_1 AVX2)
        ocv_add_dispatched_file(smooth SSE2 SSE4_1 AVX2)
        ocv_add_dispatched_file(sumpixels SSE2 AVX2 AVX512_SKX)
        xgd_internal_build_opencv(
                imgproc
                SRC_DIRS
                SRC_FILES
                ${OPENCV_MODULE_${the_module}_SOURCES_DISPATCHED}
        )
    endfunction()
    xgd_build_opencv_imgproc()
    xgd_link_opencv(opencv_imgproc PUBLIC core)
endfunction()
