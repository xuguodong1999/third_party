macro(xgd_external_find_package)
    if (XGD_USE_OPENMP AND NOT ANDROID) # on android, openmp is always available
        find_package(OpenMP QUIET)
        if (NOT OpenMP_CXX_FOUND)
            set(XGD_USE_OPENMP OFF CACHE INTERNAL "" FORCE)
            message(WARNING "XGD_USE_OPENMP set to OFF:"
                    " OpenMP_CXX_FOUND=\"${OpenMP_CXX_FOUND}\""
                    " ANDROID=\"${ANDROID}\"")
        endif ()
    endif ()

    if (XGD_USE_CUDA)
        if (MSVC OR ((CMAKE_SYSTEM_NAME STREQUAL "Linux") AND (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")))
            find_package(CUDAToolkit QUIET)
            if (NOT CUDAToolkit_FOUND)
                set(XGD_USE_CUDA OFF CACHE INTERNAL "" FORCE)
                message(WARNING "XGD_USE_CUDA set to OFF:"
                        " CUDAToolkit_FOUND=\"${CUDAToolkit_FOUND}\"")
            endif ()
        else ()
            set(XGD_USE_CUDA OFF CACHE INTERNAL "" FORCE)
            message(WARNING "XGD_USE_CUDA set to OFF:"
                    " MSVC=\"${MSVC}\""
                    " CMAKE_CXX_COMPILER_ID=\"${CMAKE_CXX_COMPILER_ID}\""
                    " CMAKE_SYSTEM_NAME=\"${CMAKE_SYSTEM_NAME}\"")
        endif ()
    endif ()

    if (XGD_USE_QT)
        find_package(QT NAMES Qt6 QUIET)
        if (QT_FOUND)
            find_package(Qt${QT_VERSION_MAJOR} COMPONENTS ${XGD_QT_MODULES} QUIET)
            foreach (_XGD_QT_MODULE ${XGD_QT_MODULES})
                if (NOT ${Qt${QT_VERSION_MAJOR}${_XGD_QT_MODULE}_FOUND})
                    set(XGD_USE_QT OFF CACHE INTERNAL "" FORCE)
                    set(_XGD_QT_MODULE_FOUND "Qt${QT_VERSION_MAJOR}${_XGD_QT_MODULE}_FOUND")
                    message(WARNING "XGD_USE_QT set to OFF:"
                            " QT_FOUND=\"${QT_FOUND}\""
                            " CMAKE_PREFIX_PATH=\"${CMAKE_PREFIX_PATH}\""
                            " ${_XGD_QT_MODULE_FOUND}=\"${${_XGD_QT_MODULE_FOUND}}\"")
                    break()
                endif ()
            endforeach ()
        else ()
            set(XGD_USE_QT OFF CACHE INTERNAL "" FORCE)
            message(WARNING "XGD_USE_QT set to OFF:"
                    " QT_FOUND=\"${QT_FOUND}\""
                    " CMAKE_PREFIX_PATH=\"${CMAKE_PREFIX_PATH}\"")
        endif ()
        if (XGD_USE_QT)
            find_package(Qt${QT_VERSION_MAJOR} COMPONENTS ${XGD_OPTIONAL_QT_MODULES} QUIET)
            foreach (_XGD_QT_MODULE ${XGD_OPTIONAL_QT_MODULES})
                if (NOT ${Qt${QT_VERSION_MAJOR}${_XGD_QT_MODULE}_FOUND})
                    set(_XGD_QT_MODULE_FOUND "Qt${QT_VERSION_MAJOR}${_XGD_QT_MODULE}_FOUND")
                    message(WARNING "XGD_OPTIONAL_QT_MODULES:"
                            " ${_XGD_QT_MODULE_FOUND}=\"${${_XGD_QT_MODULE_FOUND}}\"")
                endif ()
            endforeach ()
        endif ()
    endif ()

    if (XGD_USE_VK)
        find_package(Vulkan COMPONENTS shaderc_combined QUIET)
        if (ANDROID AND NOT Vulkan_shaderc_combined_LIBRARY)
            find_package(Vulkan QUIET)
            while (1)
                if (NOT Vulkan_FOUND)
                    break()
                endif ()
                if (ANDROID_NDK AND NOT Vulkan_GLSLC_EXECUTABLE)
                    file(GLOB GLSLC_FOLDERS ${ANDROID_NDK}/shader-tools/*)
                    find_program(Vulkan_GLSLC_EXECUTABLE glslc HINTS ${GLSLC_FOLDERS} QUIET)
                endif ()
                if (NOT Vulkan_GLSLC_EXECUTABLE)
                    break()
                endif ()
                if (ANDROID_NDK AND NOT Vulkan_shaderc_combined_LIBRARY)
                    set(_XGD_ANDROID_SHADERC_SOURCE_DIR ${ANDROID_NDK}/sources/third_party/shaderc)
                    find_library(Vulkan_shaderc_combined_LIBRARY
                            HINTS ${_XGD_ANDROID_SHADERC_SOURCE_DIR}/libs/${ANDROID_STL}/${ANDROID_ABI}
                            NAMES libshaderc.a
                            QUIET)
                    set(Vulkan_ANDROID_INCLUDE_DIR ${_XGD_ANDROID_SHADERC_SOURCE_DIR}/third_party
                            ${_XGD_ANDROID_SHADERC_SOURCE_DIR}/third_party/glslang
                            CACHE INTERNAL "shaderc include directory" FORCE)
                endif ()
                break()
            endwhile ()
        endif ()
        if (NOT (Vulkan_FOUND AND Vulkan_GLSLC_EXECUTABLE AND Vulkan_shaderc_combined_LIBRARY))
            set(XGD_USE_VK OFF CACHE INTERNAL "" FORCE)
            message(WARNING "XGD_USE_VK set to OFF:"
                    " Vulkan_FOUND=\"${Vulkan_FOUND}\""
                    " ANDROID_NDK=\"${ANDROID_NDK}\""
                    " ANDROID_STL=\"${ANDROID_STL}\""
                    " ANDROID_ABI=\"${ANDROID_ABI}\""
                    " Vulkan_GLSLC_EXECUTABLE=\"${Vulkan_GLSLC_EXECUTABLE}\""
                    " Vulkan_shaderc_combined_LIBRARY=\"${Vulkan_shaderc_combined_LIBRARY}\"")
        endif ()
    endif ()

    if (XGD_USE_TORCH)
        find_package(Torch QUIET)
        if (NOT Torch_FOUND)
            set(XGD_USE_TORCH OFF CACHE INTERNAL "" FORCE)
            message(WARNING "XGD_USE_TORCH set to OFF:"
                    " Torch_DIR=\"${Torch_DIR}\""
                    " Torch_FOUND=\"${Torch_FOUND}\"")
        else ()
            set(TORCH_INCLUDE_DIRS ${TORCH_INCLUDE_DIRS} CACHE INTERNAL "" FORCE)
            set(TORCH_LIBRARIES ${TORCH_LIBRARIES} CACHE INTERNAL "" FORCE)
        endif ()
    endif ()
endmacro()
function(xgd_external_find_runtime)
    if (NOT XGD_NODEJS_RUNTIME)
        find_program(_XGD_NODEJS_RUNTIME NAMES node QUIET)
        if (_XGD_NODEJS_RUNTIME)
            set(XGD_NODEJS_RUNTIME ${_XGD_NODEJS_RUNTIME} CACHE INTERNAL "" FORCE)
        else ()
            message(STATUS "node not found. XGD_NODEJS_RUNTIME set to \"${XGD_NODEJS_RUNTIME}\"")
        endif ()
    endif ()
    if (XGD_NODEJS_RUNTIME)
        message(STATUS "node: use \"${XGD_NODEJS_RUNTIME}\"")
    endif ()

    if (NOT XGD_WINE64_RUNTIME)
        find_program(_XGD_WINE64_RUNTIME NAMES wine64 QUIET)
        if (_XGD_WINE64_RUNTIME)
            set(XGD_WINE64_RUNTIME ${_XGD_WINE64_RUNTIME} CACHE INTERNAL "" FORCE)
        else ()
            message(STATUS "wine64 not found. XGD_WINE64_RUNTIME set to \"${XGD_WINE64_RUNTIME}\"")
        endif ()
    endif ()
    if (XGD_WINE64_RUNTIME)
        message(STATUS "wine64: use \"${XGD_WINE64_RUNTIME}\"")
    endif ()

    if (XGD_USE_CCACHE)
        find_program(_XGD_CCACHE_RUNTIME ccache QUIET)
        if (MSVC OR (EMSCRIPTEN AND CMAKE_HOST_WIN32) OR (NOT _XGD_CCACHE_RUNTIME)) # skip windows-rc, windows-emcc
            set(XGD_USE_CCACHE OFF CACHE INTERNAL "" FORCE)
            message(WARNING "XGD_USE_CCACHE set to OFF:"
                    " CCACHE_RUNTIME=\"${CCACHE_RUNTIME}\""
                    " MSVC=\"${MSVC}\" EMSCRIPTEN=\"${EMSCRIPTEN}\""
                    " CMAKE_HOST_WIN32=\"${CMAKE_HOST_WIN32}\"")
        else ()
            set(XGD_CCACHE_RUNTIME ${_XGD_CCACHE_RUNTIME} CACHE INTERNAL "" FORCE)
            set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${XGD_CCACHE_RUNTIME})
            set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ${XGD_CCACHE_RUNTIME})
        endif ()
    endif ()

endfunction()
function(xgd_external_check_env)

    include(CheckCXXCompilerFlag)
    include(CheckIncludeFiles)
    include(CheckSymbolExists)
    include(CheckFunctionExists)

    set(_XGD_BOOST_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/boost-src/boost/libs)
    set(_XGD_BOOST_CHECK_DIR ${_XGD_BOOST_DIR}/config/checks/architecture)

    set(_CMAKE_CXX_STANDARD ${CMAKE_CXX_STANDARD})
    set(_CMAKE_CXX_STANDARD_REQUIRED ${CMAKE_CXX_STANDARD_REQUIRED})
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)

    # check 32/64
    check_cxx_source_compiles("
            #include <${_XGD_BOOST_CHECK_DIR}/64.cpp>
            int main() {}" _XGD_BOOST_ARCH_64)
    if (NOT _XGD_BOOST_ARCH_64)
        check_cxx_source_compiles("
            #include <${_XGD_BOOST_CHECK_DIR}/32.cpp>
            int main() {}" _XGD_BOOST_ARCH_32)
    endif ()

    if (EMSCRIPTEN)
        check_cxx_compiler_flag("-msimd128" _XGD_WASM_SIMD128)
    else ()
        # check x86/arm/mips/power
        while (1)
            check_cxx_source_compiles("
                #include <${_XGD_BOOST_CHECK_DIR}/x86.cpp>
                int main() {}" _XGD_BOOST_ARCH_X86)
            if (_XGD_BOOST_ARCH_X86)
                break()
            endif ()
            check_cxx_source_compiles("
                #include <${_XGD_BOOST_CHECK_DIR}/arm.cpp>
                int main() {}" _XGD_BOOST_ARCH_ARM)
            if (_XGD_BOOST_ARCH_ARM)
                break()
            endif ()
            check_cxx_source_compiles("
                #include <${CHECK_SRC_DIR}/mips.cpp>
                int main() {}" _XGD_BOOST_ARCH_MIPS)
            if (_XGD_BOOST_ARCH_MIPS)
                break()
            endif ()
            check_cxx_source_compiles("
                #include <${CHECK_SRC_DIR}/power.cpp>
                int main() {}" _XGD_BOOST_ARCH_POWER)
        endwhile ()
    endif ()

    if (XGD_OPT_ARCH_32 AND NOT _XGD_BOOST_ARCH_32)
        set(XGD_OPT_ARCH_32 OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_OPT_ARCH_64 AND NOT _XGD_BOOST_ARCH_64)
        set(XGD_OPT_ARCH_64 OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_OPT_ARCH_X86 AND NOT _XGD_BOOST_ARCH_X86)
        set(XGD_OPT_ARCH_X86 OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_OPT_ARCH_ARM AND NOT _XGD_BOOST_ARCH_ARM)
        set(XGD_OPT_ARCH_ARM OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_OPT_ARCH_MIPS AND NOT _XGD_BOOST_ARCH_MIPS)
        set(XGD_OPT_ARCH_MIPS OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_OPT_ARCH_POWER AND NOT _XGD_BOOST_ARCH_POWER)
        set(XGD_OPT_ARCH_POWER OFF CACHE INTERNAL "" FORCE)
    endif ()

    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        check_cxx_compiler_flag("-march=native" _XGD_MARCH_NATIVE)
    endif ()
    if (XGD_OPT_ARCH_X86 AND NOT EMSCRIPTEN)
        if (MSVC)
            # /arch:SSE and /arch:SSE2 doesn't work and is enabled by default
            set(_XGD_FLAG_SSE_ALL 1)
            check_cxx_compiler_flag("/arch:AVX" _XGD_FLAG_AVX)
            check_cxx_compiler_flag("/arch:AVX2" _XGD_FLAG_AVX2)
            # /arch:AVX2 should also emit xop, f16c and fma intrinsic
            set(_XGD_FLAG_F16C ${_XGD_FLAG_AVX2})
            set(_XGD_FLAG_FMA ${_XGD_FLAG_AVX2})
            set(_XGD_FLAG_XOP ${_XGD_FLAG_AVX2})
        else ()
            check_cxx_compiler_flag("-msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2" _XGD_FLAG_SSE_ALL)
            check_cxx_compiler_flag("-mfma" _XGD_FLAG_FMA)
            check_cxx_compiler_flag("-mf16c" _XGD_FLAG_F16C)
            check_cxx_compiler_flag("-xop" _XGD_FLAG_XOP)
            check_cxx_compiler_flag("-mavx" _XGD_FLAG_AVX)
            check_cxx_compiler_flag("-mavx2" _XGD_FLAG_AVX2)
        endif ()
    endif ()

    if (XGD_FLAG_NEON AND NOT (XGD_OPT_ARCH_64 AND XGD_OPT_ARCH_ARM))
        set(XGD_FLAG_NEON OFF CACHE INTERNAL "" FORCE)
    endif ()

    if (XGD_FLAG_MARCH_NATIVE AND NOT _XGD_MARCH_NATIVE)
        set(XGD_FLAG_MARCH_NATIVE OFF CACHE INTERNAL "" FORCE)
    endif ()

    if (XGD_FLAG_WASM_SIMD128 AND NOT _XGD_WASM_SIMD128)
        set(XGD_FLAG_WASM_SIMD128 OFF CACHE INTERNAL "" FORCE)
    endif ()

    if (XGD_FLAG_SSE_ALL AND NOT _XGD_FLAG_SSE_ALL)
        set(XGD_FLAG_SSE_ALL OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_FLAG_AVX AND NOT _XGD_FLAG_AVX)
        set(XGD_FLAG_AVX OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_FLAG_AVX2 AND NOT _XGD_FLAG_AVX2)
        set(XGD_FLAG_AVX2 OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_FLAG_F16C AND NOT _XGD_FLAG_F16C)
        set(XGD_FLAG_F16C OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_FLAG_FMA AND NOT _XGD_FLAG_FMA)
        set(XGD_FLAG_FMA OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_FLAG_XOP AND NOT _XGD_FLAG_XOP)
        set(XGD_FLAG_XOP OFF CACHE INTERNAL "" FORCE)
    endif ()
    # include(ProcessorCount)
    # ProcessorCount(_XGD_PROCESSOR_COUNT)

    # boost check
    if (XGD_OPT_ARCH_X86 AND NOT EMSCRIPTEN)
        check_cxx_source_compiles(
                "#include <${_XGD_BOOST_DIR}/atomic/config/has_sse2.cpp>"
                XGD_BOOST_HAS_SSE2
        )
        check_cxx_source_compiles(
                "#include <${_XGD_BOOST_DIR}/atomic/config/has_sse41.cpp>"
                XGD_BOOST_HAS_SSE41
        )
    endif ()
    check_cxx_source_compiles(
            "#include <${_XGD_BOOST_DIR}/filesystem/config/has_cxx20_atomic_ref.cpp>"
            XGD_BOOST_HAS_CXX20_ATOMIC_REF
    )

    # openbabel
    check_symbol_exists(rint "math.h" XGD_HAVE_RINT)
    check_symbol_exists(snprintf "stdio.h" XGD_HAVE_SNPRINTF)
    check_symbol_exists(sranddev "stdlib.h" XGD_HAVE_SRANDDEV)
    check_symbol_exists(strcasecmp "string.h" XGD_HAVE_STRCASECMP)
    check_symbol_exists(strncasecmp "string.h" XGD_HAVE_STRNCASECMP)
    if (NOT MSVC)
        check_include_files(sys/time.h XGD_HAVE_SYS_TIME_H)
        check_include_files(rpc/xdr.h XGD_HAVE_RPC_XDR_H)
        # xml
        check_include_files(unistd.h XGD_HAVE_UNISTD_H)
        check_include_files(stdint.h XGD_HAVE_STDINT_H)
        check_include_files(pthread.h XGD_HAVE_PTHREAD_H)
        check_include_files(fcntl.h XGD_HAVE_FCNTL_H)
        check_include_files(sys/stat.h XGD_HAVE_SYS_STAT_H)
        check_function_exists(stat XGD_HAVE_STAT)
    endif ()
    # cpu_features
    # check_include_file(dlfcn.h XGD_HAVE_DLFCN_H)
    check_symbol_exists(getauxval "sys/auxv.h" XGD_HAVE_STRONG_GETAUXVAL)

    set(CMAKE_CXX_STANDARD ${_CMAKE_CXX_STANDARD})
    set(CMAKE_CXX_STANDARD_REQUIRED ${_CMAKE_CXX_STANDARD_REQUIRED})
    unset(_CMAKE_CXX_STANDARD)
    unset(_CMAKE_CXX_STANDARD_REQUIRED)

    set(_XGD_VARS
            XGD_USE_OPENMP
            XGD_USE_CUDA
            XGD_USE_QT
            XGD_USE_VK
            XGD_USE_TORCH
            XGD_USE_CCACHE

            XGD_OPT_ARCH_X86
            XGD_OPT_ARCH_ARM
            XGD_OPT_ARCH_MIPS
            XGD_OPT_ARCH_POWER
            XGD_OPT_ARCH_32
            XGD_OPT_ARCH_64

            XGD_FLAG_NEON
            XGD_FLAG_FMA
            XGD_FLAG_F16C
            XGD_FLAG_XOP
            XGD_FLAG_SSE_ALL
            XGD_FLAG_AVX
            XGD_FLAG_AVX2
            XGD_FLAG_MARCH_NATIVE
            XGD_FLAG_WASM_SIMD128

            XGD_BUILD_WITH_GRADLE
            XGD_NO_DEBUG_CONSOLE

            XGD_WINE64_RUNTIME
            XGD_NODEJS_RUNTIME
            XGD_POSTFIX
            XGD_WASM_ENV
            XGD_QT_MODULES)

    message(STATUS "Summary: ")
    foreach (_XGD_VAR ${_XGD_VARS})
        message(STATUS "\t${_XGD_VAR}: ${${_XGD_VAR}}")
    endforeach ()
endfunction()
function(xgd_configure_file_copy_only TARGET IN_FILE OUT_FILE)
    configure_file(${IN_FILE} ${OUT_FILE} COPYONLY)
    target_sources(${TARGET} PRIVATE ${OUT_FILE})
endfunction()

# disable compiler warning ! only for 3rdparty libs
function(xgd_disable_warnings TARGET)
    target_compile_options(
            ${TARGET}
            PRIVATE
            $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:-w>
            $<$<CXX_COMPILER_ID:MSVC>:/w>
    )
endfunction()

function(xgd_target_global_options TARGET)
    cmake_parse_arguments(param "" "CXX_STANDARD" "" ${ARGN})
    set(_XGD_COMPILE_OPTIONS "")
    set(_XGD_COMPILE_DEFINITIONS "")
    set(_XGD_LINK_OPTIONS "")
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        # _GLIBCXX_USE_CXX11_ABI=1
        list(APPEND _XGD_COMPILE_OPTIONS -Werror=return-type)
    endif ()
    if (WIN32)
        list(APPEND _XGD_COMPILE_DEFINITIONS _USE_MATH_DEFINES) # for M_PI macro
    endif ()
    if (MSVC)
        list(APPEND _XGD_COMPILE_OPTIONS
                /MP             # multi processor build
                /utf-8          # correct msvc charset
                /bigobj         # big obj
                # get correct __cplusplus macro
                /Zc:__cplusplus)
        list(APPEND _XGD_LINK_OPTIONS /manifest:no) # do not generate manifest
        # crt
        # set_target_properties(${TARGET} PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    endif ()
    if (EMSCRIPTEN)
        list(APPEND _XGD_COMPILE_OPTIONS
                -frtti
                -fexceptions
                -sUSE_PTHREADS=1)
        list(APPEND _XGD_LINK_OPTIONS
                -fexceptions
                -frtti
                -sALLOW_BLOCKING_ON_MAIN_THREAD=1
                -sASSERTIONS=1
                -sASYNCIFY
                -sPTHREAD_POOL_SIZE_STRICT=0
                -sSAFE_HEAP=1
                # -sSINGLE_FILE=1
                -sTOTAL_MEMORY=1024MB
                -sTOTAL_STACK=4MB
                -sUSE_PTHREADS=1)
        if (XGD_WASM_ENV)
            list(APPEND _XGD_LINK_OPTIONS
                    # -sPROXY_TO_PTHREAD
                    # -sEXIT_RUNTIME=1
                    # -sPTHREAD_POOL_SIZE=16
                    -sENVIRONMENT=${XGD_WASM_ENV})
        endif ()
        if (XGD_FLAG_WASM_SIMD128)
            list(APPEND _XGD_COMPILE_OPTIONS -msimd128)
            list(APPEND _XGD_COMPILE_DEFINITIONS __SSE__ __SSE2__)
        endif ()
    else ()
        if (XGD_FLAG_MARCH_NATIVE)
            list(APPEND _XGD_COMPILE_OPTIONS -march=native)
        endif ()
        if (XGD_OPT_ARCH_X86)
            if (XGD_FLAG_SSE_ALL)
                list(APPEND _XGD_COMPILE_DEFINITIONS __SSE__ __SSE2__ __SSE3__ __SSSE3__ __SSE4_1__ __SSE4_2__)
            endif ()
            if (XGD_FLAG_AVX)
                list(APPEND _XGD_COMPILE_DEFINITIONS __AVX__)
            endif ()
            if (XGD_FLAG_AVX2)
                list(APPEND _XGD_COMPILE_DEFINITIONS __AVX2__)
            endif ()
            if (XGD_FLAG_FMA)
                list(APPEND _XGD_COMPILE_DEFINITIONS __FMA__)
            endif ()
            if (XGD_FLAG_F16C)
                list(APPEND _XGD_COMPILE_DEFINITIONS __F16C__)
            endif ()

            if (MSVC)
                if (XGD_FLAG_AVX)
                    list(APPEND _XGD_COMPILE_OPTIONS /arch:AVX)
                endif ()
                if (XGD_FLAG_AVX2)
                    list(APPEND _XGD_COMPILE_OPTIONS /arch:AVX2)
                endif ()
            else ()
                if (XGD_FLAG_SSE_ALL)
                    list(APPEND _XGD_COMPILE_OPTIONS -msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2)
                endif ()
                if (XGD_FLAG_AVX)
                    list(APPEND _XGD_COMPILE_OPTIONS -mavx)
                endif ()
                if (XGD_FLAG_AVX2)
                    list(APPEND _XGD_COMPILE_OPTIONS -mavx2)
                endif ()
                if (XGD_FLAG_FMA)
                    list(APPEND _XGD_COMPILE_OPTIONS -mfma)
                endif ()
                if (XGD_FLAG_F16C)
                    list(APPEND _XGD_COMPILE_OPTIONS -mf16c)
                endif ()
            endif ()
        endif ()
    endif ()

    if (_XGD_COMPILE_DEFINITIONS)
        target_compile_definitions(${TARGET} PRIVATE $<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:${_XGD_COMPILE_DEFINITIONS}>)
    endif ()
    if (_XGD_COMPILE_OPTIONS)
        target_compile_options(${TARGET} PRIVATE $<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:${_XGD_COMPILE_OPTIONS}>)
    endif ()
    if (_XGD_LINK_OPTIONS)
        target_link_options(${TARGET} PRIVATE ${_XGD_LINK_OPTIONS})
    endif ()
    set(_XGD_CXX_STANDARD 20)
    if (param_CXX_STANDARD)
        set(_XGD_CXX_STANDARD ${param_CXX_STANDARD})
    endif ()
    set_target_properties(
            ${TARGET} PROPERTIES
            C_STANDARD 11       # C11
            C_STANDARD_REQUIRED ON
            CXX_STANDARD ${_XGD_CXX_STANDARD}
            CXX_STANDARD_REQUIRED ON
            CUDA_STANDARD 17    # CUDA C++17
            CUDA_STANDARD_REQUIRED ON
            # Export only public symbols
            CXX_VISIBILITY_PRESET hidden
            VISIBILITY_INLINES_HIDDEN ON
            POSITION_INDEPENDENT_CODE ON
            CMAKE_DEBUG_POSTFIX "${XGD_POSTFIX}"
    )
    if (NOT (MINGW AND (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"))) # mxe heavily dependent on extensions
        set_target_properties(${TARGET} PROPERTIES CXX_EXTENSIONS OFF)
    endif ()
endfunction()

function(xgd_mark_generated TARGETS)
    set_source_files_properties(${TARGETS} PROPERTIES GENERATED TRUE)
endfunction()

# common library
function(xgd_add_library TARGET)
    # usage
    # xgd_add_library(your-awesome-target SRC_DIRS [...] SRC_FILES [...] INCLUDE_DIRS [...] PRIVATE_INCLUDE_DIRS [...])
    cmake_parse_arguments(
            param
            "STATIC;SHARED;OBJECT"
            ""
            "SRC_DIRS;SRC_FILES;INCLUDE_DIRS;PRIVATE_INCLUDE_DIRS;EXCLUDE_SRC_FILES;EXCLUDE_REGEXES"
            ${ARGN}
    )
    foreach (SRC_DIR ${param_SRC_DIRS})
        aux_source_directory(${SRC_DIR} ${TARGET}_SOURCES)
    endforeach ()
    foreach (EXCLUDE_REGEX ${param_EXCLUDE_REGEXES})
        list(FILTER ${TARGET}_SOURCES EXCLUDE REGEX "${EXCLUDE_REGEX}")
    endforeach ()
    list(APPEND ${TARGET}_SOURCES ${param_SRC_FILES})
    foreach (EXCLUDE_SRC_FILE ${param_EXCLUDE_SRC_FILES})
        list(REMOVE_ITEM ${TARGET}_SOURCES ${EXCLUDE_SRC_FILE})
    endforeach ()
    if (param_OBJECT)
        add_library(${TARGET} OBJECT ${${TARGET}_SOURCES})
    elseif (param_STATIC)
        add_library(${TARGET} STATIC ${${TARGET}_SOURCES})
    elseif (param_SHARED)
        add_library(${TARGET} SHARED ${${TARGET}_SOURCES})
    else ()
        add_library(${TARGET} ${${TARGET}_SOURCES})
    endif ()
    xgd_lib_apply_release_info(${TARGET})
    target_include_directories(
            ${TARGET}
            PUBLIC ${param_INCLUDE_DIRS}
            PRIVATE ${param_PRIVATE_INCLUDE_DIRS}
    )
    xgd_target_global_options(${TARGET})
endfunction()

function(xgd_generate_export_header TARGET BASE_NAME EXT)
    set(EXPORT_HEADER_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/${BASE_NAME}/include)
    include(GenerateExportHeader)
    generate_export_header(
            ${TARGET}
            BASE_NAME ${BASE_NAME}
            EXPORT_FILE_NAME "${EXPORT_HEADER_INCLUDE_DIR}/${BASE_NAME}_export${EXT}"
    )
    target_include_directories(
            ${TARGET}
            PUBLIC
            ${EXPORT_HEADER_INCLUDE_DIR}
    )
endfunction()

function(xgd_generate_export_header_modules TARGET BASE_NAME MODULE_NAME EXT)
    set(EXPORT_HEADER_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/${BASE_NAME}/include)
    include(GenerateExportHeader)
    generate_export_header(
            ${TARGET}
            BASE_NAME "${BASE_NAME}_${MODULE_NAME}"
            EXPORT_FILE_NAME
            "${EXPORT_HEADER_INCLUDE_DIR}/${MODULE_NAME}/${BASE_NAME}_export${EXT}"
    )
    target_include_directories(
            ${TARGET}
            PUBLIC
            ${EXPORT_HEADER_INCLUDE_DIR}
    )
endfunction()

function(xgd_lib_apply_release_info TARGET)
    set(RC_FILE ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/msvc_release.rc)
    if (NOT (XGD_PRODUCTION_BUILD AND EXISTS ${RC_FILE}))
        return()
    endif ()
    if (WIN32)
        target_sources(${TARGET} PRIVATE ${RC_FILE})
    endif ()
endfunction()

# remove unused 3rdparty lib from cmake "all" target
function(xgd_exclude_from_all TARGET)
    cmake_parse_arguments(param "DISABLE" "" "" ${ARGN})
    if (NOT param_DISABLE)
        set_target_properties(${TARGET} PROPERTIES EXCLUDE_FROM_ALL ON)
    else ()
        set_target_properties(${TARGET} PROPERTIES EXCLUDE_FROM_ALL OFF)
    endif ()
endfunction()

function(xgd_generate_text_assets TARGET BASE_NAME)
    cmake_parse_arguments(param "" "" "SRC_FILES" ${ARGN})
    set(ASSET_INC_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/${BASE_NAME}/include)
    set(ASSET_INC_FILE ${ASSET_INC_DIR}/text_assets.hpp)
    set(ASSET_SRC_FILE ${CMAKE_CURRENT_BINARY_DIR}/generated/${BASE_NAME}/src/text_assets.cpp)
    set(NEED_UPDATE 0)
    foreach (SRC_FILE ${param_SRC_FILES})
        if (NOT EXISTS ${SRC_FILE})
            message(FATAL_ERROR "generate_text_assets: ${SRC_FILE} not exist")
        endif ()
    endforeach ()
    if (EXISTS ${ASSET_INC_FILE} AND EXISTS ${ASSET_SRC_FILE})
        foreach (SRC_FILE ${param_SRC_FILES})
            if ("${SRC_FILE}" IS_NEWER_THAN "${ASSET_SRC_FILE}")
                set(NEED_UPDATE 1)
                break()
            endif ()
        endforeach ()
    else ()
        set(NEED_UPDATE 1)
    endif ()
    target_include_directories(${TARGET} PRIVATE ${ASSET_INC_DIR})
    if (NOT NEED_UPDATE)
        target_sources(${TARGET} PRIVATE ${ASSET_SRC_FILE})
        return()
    endif ()
    string(TOUPPER ${BASE_NAME} CPP_VARIABLE_NAME)
    set(INC_BUFFER "#include <unordered_map>\n")
    string(APPEND INC_BUFFER "#include <string>\n")
    string(APPEND INC_BUFFER "namespace ${BASE_NAME} {\n")
    string(APPEND INC_BUFFER "extern const std::unordered_map<std::string, std::string> ${CPP_VARIABLE_NAME}_ASSET_MAP;\n")
    string(APPEND INC_BUFFER "}")

    set(SRC_BUFFER "#include \"text_assets.hpp\"\n")
    string(APPEND SRC_BUFFER "using namespace std;\n")
    string(APPEND SRC_BUFFER "const unordered_map<string, string> ${BASE_NAME}::${CPP_VARIABLE_NAME}_ASSET_MAP{\n")
    foreach (SRC_FILE ${param_SRC_FILES})
        get_filename_component(SRC_FILE_NAME ${SRC_FILE} NAME)
        string(APPEND SRC_BUFFER "{R\"(${SRC_FILE_NAME})\",")
        file(READ "${SRC_FILE}" FILE_CONTENT)
        string(REPLACE "\"" "\\\"" FILE_CONTENT ${FILE_CONTENT})
        # for MSVC C2026: split large string to 16kb chunks
        macro(SPLIT_BY_CHUNK)
            math(EXPR CHUNK_SIZE "16*1024-4")
            string(LENGTH ${FILE_CONTENT} FILE_LENGTH)
            set(BEG 0)
            set(CHUNKED_CONTENT "")
            while (${BEG} LESS ${FILE_LENGTH})
                math(EXPR OFFSET "${FILE_LENGTH}-${BEG}+1")
                if (${OFFSET} GREATER ${CHUNK_SIZE})
                    set(OFFSET ${CHUNK_SIZE})
                endif ()
                string(SUBSTRING ${FILE_CONTENT} ${BEG} ${OFFSET} CHUNK_STRING)
                string(APPEND CHUNKED_CONTENT "R\"(${CHUNK_STRING})\" ")
                math(EXPR BEG "${BEG}+${OFFSET}")
            endwhile ()
            string(APPEND SRC_BUFFER "${CHUNKED_CONTENT}},\n")
        endmacro()
        if (MSVC)
            SPLIT_BY_CHUNK()
        else ()
            string(APPEND SRC_BUFFER "R\"(${FILE_CONTENT})\"},\n")
        endif ()
    endforeach ()
    string(APPEND SRC_BUFFER "};")
    file(WRITE ${ASSET_INC_FILE} "${INC_BUFFER}")
    file(WRITE ${ASSET_SRC_FILE} "${SRC_BUFFER}")
    target_sources(${TARGET} PRIVATE ${ASSET_SRC_FILE})
endfunction()

# common executable
function(xgd_add_executable TARGET)
    cmake_parse_arguments(
            param
            "BUNDLE_QT_GUI"
            ""
            "SRC_DIRS;SRC_FILES;INCLUDE_DIRS;EXCLUDE_SRC_FILES;EXCLUDE_REGEXES"
            ${ARGN}
    )
    foreach (SRC_DIR ${param_SRC_DIRS})
        aux_source_directory(${SRC_DIR} ${TARGET}_SOURCES)
    endforeach ()
    foreach (EXCLUDE_REGEX ${param_EXCLUDE_REGEXES})
        list(FILTER ${TARGET}_SOURCES EXCLUDE REGEX "${EXCLUDE_REGEX}")
    endforeach ()
    list(APPEND ${TARGET}_SOURCES ${param_SRC_FILES})
    foreach (EXCLUDE_SRC_FILE ${param_EXCLUDE_SRC_FILES})
        list(REMOVE_ITEM ${TARGET}_SOURCES ${EXCLUDE_SRC_FILE})
    endforeach ()

    if (ANDROID)
        ## if use qt_add_executable in CI, use the following codes to skip apk build in "all" target
        # set(ANDROID_PACKAGE_SOURCE_DIR ${XGD_ASSET_DIR}/android/${TARGET})
        # if (EXISTS ${ANDROID_PACKAGE_SOURCE_DIR}/AndroidManifest.xml)
        #     set_target_properties(${TARGET} PROPERTIES QT_ANDROID_PACKAGE_SOURCE_DIR ${ANDROID_PACKAGE_SOURCE_DIR})
        # endif ()
        if (param_BUNDLE_QT_GUI)
            qt_add_executable(${TARGET} MANUAL_FINALIZATION ${${TARGET}_SOURCES})
            qt_finalize_target(${TARGET})
            xgd_exclude_from_all(${TARGET}_prepare_apk_dir)
            xgd_exclude_from_all(apk_all)
        else ()
            # do not run qt_add_executable here, we use customized android shell project
            add_executable(${TARGET} ${${TARGET}_SOURCES})
        endif ()
    elseif (EMSCRIPTEN) # web environment
        if (XGD_WASM_NODE)
            add_executable(${TARGET} ${${TARGET}_SOURCES})
        elseif (param_BUNDLE_QT_GUI)
            qt_add_executable(${TARGET} ${${TARGET}_SOURCES})
            set_target_properties(
                    ${TARGET} PROPERTIES
                    RUNTIME_OUTPUT_DIRECTORY ${XGD_FRONTEND_DIR}/homepage/dist-qt/${TARGET}
                    # QT_WASM_PTHREAD_POOL_SIZE navigator.hardwareConcurrency
                    QT_WASM_PTHREAD_POOL_SIZE 4
            )
            target_link_options(${TARGET} PRIVATE -sPTHREAD_POOL_SIZE_STRICT=0)
        else ()
            # Qt${QT_VERSION_MAJOR}::Platform have "-sMODULARIZE=1;-sEXPORT_NAME=createQtAppInstance" linker flags
            # TO run output js file in CI, intentionally call exposed function at the end
            # e.g. node -e 'import("./hello-opencv.js").then(m=>m?.default?.())'
            add_executable(${TARGET} ${${TARGET}_SOURCES})
            target_link_options(${TARGET} PRIVATE -sPTHREAD_POOL_SIZE=4)
        endif ()
    else ()
        if (param_BUNDLE_QT_GUI)
            qt_add_executable(${TARGET} ${${TARGET}_SOURCES})
            xgd_program_apply_release_info(${TARGET})
        else ()
            add_executable(${TARGET} ${${TARGET}_SOURCES})
        endif ()
    endif ()
    target_include_directories(${TARGET} PRIVATE ${param_INCLUDE_DIRS})
    xgd_target_global_options(${TARGET})
    set_target_properties(${TARGET} PROPERTIES BUNDLE_QT_GUI "${param_BUNDLE_QT_GUI}")
    if (ANDROID AND param_BUNDLE_QT_GUI)
        # expose main function
        set_target_properties(${TARGET} PROPERTIES CXX_VISIBILITY_PRESET default)
    endif ()
endfunction()
# qtnodes
function(xgd_link_qtnodes TARGET)
    add_dependencies(${TARGET} QtNodes)
    target_link_libraries(${TARGET} PRIVATE QtNodes)
endfunction()

function(xgd_link_torch TARGET)
    cmake_parse_arguments(param "PUBLIC" "" "" ${ARGN})
    if (param_PUBLIC)
        target_include_directories(${TARGET} PUBLIC ${TORCH_INCLUDE_DIRS})
        target_link_libraries(${TARGET} PUBLIC ${TORCH_INCLUDE_DIRS})
    else ()
        target_include_directories(${TARGET} PRIVATE ${Torch_DIR}/../../../include ${Torch_DIR}/../../../include/torch/csrc/api/include)
        target_link_libraries(${TARGET} PRIVATE ${TORCH_LIBRARIES})
    endif ()
endfunction()

# ade
function(xgd_link_ade TARGET)
    add_dependencies(${TARGET} ade)
    target_link_libraries(${TARGET} PRIVATE ade)
endfunction()

# protobuf
function(xgd_link_protobuf TARGET)
    add_dependencies(${TARGET} protobuf)
    target_link_libraries(${TARGET} PRIVATE protobuf)
endfunction()

# absl
function(xgd_link_absl TARGET)
    add_dependencies(${TARGET} absl)
    cmake_parse_arguments(param "PUBLIC" "" "" ${ARGN})
    if (param_PUBLIC)
        target_link_libraries(${TARGET} PUBLIC absl)
    else ()
        target_link_libraries(${TARGET} PRIVATE absl)
    endif ()
endfunction()

# opencv
function(xgd_link_opencv TARGET)
    cmake_parse_arguments(param "" "" "PRIVATE;PUBLIC" ${ARGN})
    foreach (COMPONENT ${param_PRIVATE})
        add_dependencies(${TARGET} opencv_${COMPONENT})
        target_link_libraries(${TARGET} PRIVATE opencv_${COMPONENT})
    endforeach ()
    foreach (COMPONENT ${param_PUBLIC})
        add_dependencies(${TARGET} opencv_${COMPONENT})
        target_link_libraries(${TARGET} PUBLIC opencv_${COMPONENT})
    endforeach ()
endfunction()

# yoga
function(xgd_link_yoga TARGET)
    add_dependencies(${TARGET} yoga)
    target_link_libraries(${TARGET} PRIVATE yoga)
endfunction()

# spdlog
function(xgd_link_spdlog TARGET)
    add_dependencies(${TARGET} spdlog)
    target_link_libraries(${TARGET} PRIVATE spdlog)
endfunction()

# Threads::Threads
function(xgd_link_threads TARGET)
    cmake_parse_arguments(param "PUBLIC" "" "" ${ARGN})
    if (param_PUBLIC)
        target_link_libraries(${TARGET} PUBLIC Threads::Threads)
    else ()
        target_link_libraries(${TARGET} PRIVATE Threads::Threads)
    endif ()
endfunction()

# gtest
function(xgd_link_gtest TARGET)
    cmake_parse_arguments(param "GTEST;GTEST_MAIN;GMOCK_MAIN;DONT_ADD_TEST" "" "" ${ARGN})
    if (BUILD_SHARED_LIBS AND (NOT param_GTEST_MAIN) AND (NOT param_GMOCK_MAIN) AND (NOT param_DONT_ADD_TEST))
        target_compile_definitions(${TARGET} PRIVATE GTEST_LINKED_AS_SHARED_LIBRARY)
    endif ()
    if (param_GTEST)
        add_dependencies(${TARGET} gtest)
        target_link_libraries(${TARGET} PRIVATE gtest)
    elseif (param_GMOCK_MAIN)
        add_dependencies(${TARGET} gmock_main)
        target_link_libraries(${TARGET} PRIVATE gtest gmock_main)
    else () # elseif (param_GTEST_MAIN)
        add_dependencies(${TARGET} gtest_main)
        target_link_libraries(${TARGET} PRIVATE gtest gtest_main)
    endif ()
    if (NOT param_DONT_ADD_TEST)
        set(TEST_COMMAND "${TARGET}")
        get_target_property(RUNTIME_OUTPUT_DIRECTORY ${TARGET} RUNTIME_OUTPUT_DIRECTORY)
        if (NOT RUNTIME_OUTPUT_DIRECTORY)
            if (CMAKE_RUNTIME_OUTPUT_DIRECTORY)
                set(RUNTIME_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
            else ()
                set(RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
            endif ()
        endif ()
        if (EMSCRIPTEN AND NODEJS_RUNTIME)
            set(OUTPUT_JS ${RUNTIME_OUTPUT_DIRECTORY}/${TARGET}.js)
            if (CMAKE_HOST_WIN32)
                set(OUTPUT_JS "file://${OUTPUT_JS}")
            endif ()
            set(TEST_COMMAND
                    "${NODEJS_RUNTIME}"
                    "--experimental-wasm-threads"
                    "-e"
                    "import('${OUTPUT_JS}').then(m => ('function' === typeof m?.default) ? m.default() : 0)")

        elseif (XGD_WINE64_RUNTIME AND MINGW AND (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")) # mxe
            set(TEST_COMMAND
                    "${XGD_WINE64_RUNTIME}"
                    "${RUNTIME_OUTPUT_DIRECTORY}/${TARGET}.exe")
        endif ()
        add_test(NAME ${TARGET} COMMAND ${TEST_COMMAND} WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
        if (NOT TARGET gtest_all)
            add_custom_target(gtest_all)
        endif ()
        add_dependencies(gtest_all ${TARGET})
    endif ()
endfunction()

# benchmark
function(xgd_link_benchmark TARGET)
    cmake_parse_arguments(param "MAIN" "" "" ${ARGN})
    if (param_MAIN)
        add_dependencies(${TARGET} benchmark_main)
        target_link_libraries(${TARGET} PRIVATE benchmark benchmark_main)
    else ()
        add_dependencies(${TARGET} benchmark)
        target_link_libraries(${TARGET} PRIVATE benchmark)
    endif ()
    if (NOT TARGET bm_all)
        add_custom_target(bm_all)
    endif ()
    add_dependencies(bm_all ${TARGET})
endfunction()

# zlib
function(xgd_link_zlib TARGET)
    cmake_parse_arguments(param "PUBLIC" "" "" ${ARGN})
    add_dependencies(${TARGET} zlib)
    if (param_PUBLIC)
        target_link_libraries(${TARGET} PUBLIC zlib)
    else ()
        target_link_libraries(${TARGET} PRIVATE zlib)
    endif ()
endfunction()

# libxml2
function(xgd_link_xml2 TARGET)
    add_dependencies(${TARGET} xml2)
    target_link_libraries(${TARGET} PRIVATE xml2)
endfunction()

# libpng
function(xgd_link_png TARGET)
    cmake_parse_arguments(param "PUBLIC" "" "" ${ARGN})
    if (param_PUBLIC)
        target_link_libraries(${TARGET} PUBLIC png)
    else ()
        target_link_libraries(${TARGET} PRIVATE png)
    endif ()
    if (WIN32 AND BUILD_SHARED_LIBS)
        target_compile_definitions(${TARGET} PRIVATE PNG_USE_DLL)
    endif ()
endfunction()

# boost
function(xgd_link_boost TARGET)
    # usage: xgd_link_boost(your-awesome-target PRIVATE [iostreams json ...])
    cmake_parse_arguments(param "" "" "PRIVATE;PUBLIC" ${ARGN})
    if ((NOT param_PRIVATE) AND (NOT param_PUBLIC))
        message(FATAL "xgd_link_boost: no components given")
    endif ()
    set(_XGD_BOOST_ALL
            atomic
            chrono container contract
            date_time
            exception
            filesystem
            graph gil
            iostreams
            json
            nowide
            program_options
            random regex
            serialization system
            thread timer type_erasure
            stacktrace
            url
            wave)
    if (param_PRIVATE AND "all" IN_LIST param_PRIVATE)
        set(_XGD_BOOST_PRIVATE_COMPONENTS ${_XGD_BOOST_ALL})
    else ()
        set(_XGD_BOOST_PRIVATE_COMPONENTS ${param_PRIVATE})
    endif ()
    if (param_PUBLIC AND "all" IN_LIST param_PUBLIC)
        set(_XGD_BOOST_PUBLIC_COMPONENTS ${_XGD_BOOST_ALL})
    else ()
        set(_XGD_BOOST_PUBLIC_COMPONENTS ${param_PUBLIC})
    endif ()
    foreach (COMPONENT ${_XGD_BOOST_PRIVATE_COMPONENTS})
        if (NOT TARGET Boost::${COMPONENT})
            message(STATUS "boost: use Boost::${COMPONENT} as an interface")
            xgd_use_header(${TARGET} PRIVATE boost)
            continue()
        endif ()
        add_dependencies(${TARGET} Boost::${COMPONENT})
        target_link_libraries(${TARGET} PRIVATE Boost::${COMPONENT})
    endforeach ()
    foreach (COMPONENT ${_XGD_BOOST_PUBLIC_COMPONENTS})
        if (NOT TARGET Boost::${COMPONENT})
            message(STATUS "boost: use Boost::${COMPONENT} as an interface")
            xgd_use_header(${TARGET} PUBLIC boost)
            continue()
        endif ()
        add_dependencies(${TARGET} Boost::${COMPONENT})
        target_link_libraries(${TARGET} PUBLIC Boost::${COMPONENT})
    endforeach ()
    if ("gil" IN_LIST _XGD_BOOST_PRIVATE_COMPONENTS)
        xgd_link_png(${TARGET} PRIVATE)
    endif ()
    if ("gil" IN_LIST _XGD_BOOST_PUBLIC_COMPONENTS)
        xgd_link_png(${TARGET} PUBLIC)
    endif ()
endfunction()

# qt
function(xgd_link_qt TARGET)
    # usage: xgd_link_qt(your-awesome-target COMPONENTS [Core Widgets ...])
    cmake_parse_arguments(param "" "" "PUBLIC;PRIVATE" ${ARGN})
    if ((NOT param_PRIVATE) AND (NOT param_PUBLIC))
        message(FATAL "xgd_link_qt: no components given")
    endif ()
    foreach (COMPONENT ${param_PRIVATE})
        target_link_libraries(${TARGET} PRIVATE Qt${QT_VERSION_MAJOR}::${COMPONENT})
    endforeach ()
    foreach (COMPONENT ${param_PUBLIC})
        target_link_libraries(${TARGET} PUBLIC Qt${QT_VERSION_MAJOR}::${COMPONENT})
    endforeach ()
    target_compile_definitions(
            ${TARGET}
            PRIVATE QT_DISABLE_DEPRECATED_BEFORE=0x060000
            QT_NO_KEYWORDS
    )
    set_target_properties(${TARGET} PROPERTIES AUTOUIC ON AUTOMOC ON AUTORCC ON)
endfunction()

# vulkan
function(xgd_link_vulkan TARGET)
    if (TARGET Vulkan::Vulkan)
        target_link_libraries(${TARGET} PRIVATE Vulkan::Vulkan)
    else ()
        target_include_directories(${TARGET} PRIVATE ${Vulkan_INCLUDE_DIR})
        target_link_libraries(${TARGET} PRIVATE ${Vulkan_LIBRARIES})
    endif ()
    if (TARGET Vulkan::shaderc_combined)
        target_link_libraries(${TARGET} PRIVATE Vulkan::shaderc_combined)
    else ()
        target_include_directories(${TARGET} PRIVATE ${Vulkan_INCLUDE_DIR})
        target_link_libraries(${TARGET} PRIVATE ${Vulkan_shaderc_combined_LIBRARY})
    endif ()
    if (ANDROID)
        target_include_directories(${TARGET} PRIVATE ${Vulkan_ANDROID_INCLUDE_DIR})
    endif ()
endfunction()

# inchi
function(xgd_link_inchi TARGET)
    add_dependencies(${TARGET} inchi)
    target_link_libraries(${TARGET} PRIVATE inchi)
endfunction()

# maeparser
function(xgd_link_maeparser TARGET)
    add_dependencies(${TARGET} maeparser)
    target_link_libraries(${TARGET} PRIVATE maeparser)
endfunction()

# coordgenlibs
function(xgd_link_coordgen TARGET)
    add_dependencies(${TARGET} coordgenlibs)
    target_link_libraries(${TARGET} PRIVATE coordgenlibs)
endfunction()

# openbabel
function(xgd_link_openbabel TARGET)
    add_dependencies(${TARGET} openbabel)
    target_link_libraries(${TARGET} PRIVATE openbabel)
endfunction()

# yaehmop
function(xgd_link_yaehmop TARGET)
    add_dependencies(${TARGET} yaehmop)
    target_link_libraries(${TARGET} PRIVATE yaehmop)
endfunction()

# avalontoolkit
function(xgd_link_avalontoolkit TARGET)
    add_dependencies(${TARGET} avalontoolkit)
    target_link_libraries(${TARGET} PRIVATE avalontoolkit)
endfunction()

# freesasa
function(xgd_link_freesasa TARGET)
    add_dependencies(${TARGET} freesasa)
    target_link_libraries(${TARGET} PRIVATE freesasa)
endfunction()

# ringdecomposerlib
function(xgd_link_ringdecomposerlib TARGET)
    cmake_parse_arguments(param "PUBLIC" "" "" ${ARGN})
    add_dependencies(${TARGET} ringdecomposerlib)
    if (param_PUBLIC)
        target_link_libraries(${TARGET} PUBLIC ringdecomposerlib)
    else ()
        target_link_libraries(${TARGET} PRIVATE ringdecomposerlib)
    endif ()
endfunction()

# rdkit
function(xgd_link_rdkit TARGET)
    cmake_parse_arguments(param "" "" "PRIVATE;PUBLIC" ${ARGN})
    if ((NOT param_PRIVATE) AND (NOT param_PUBLIC))
        message(FATAL "xgd_link_rdkit: no components given")
    endif ()
    foreach (RDKIT_COMPONENT ${param_PRIVATE})
        # string(TOLOWER ${RDKIT_COMPONENT} RDKIT_COMPONENT_TARGET)
        set(RDKIT_COMPONENT_TARGET ${RDKIT_COMPONENT})
        set(RDKIT_COMPONENT_TARGET rdkit_${RDKIT_COMPONENT_TARGET})
        add_dependencies(${TARGET} ${RDKIT_COMPONENT_TARGET})
        target_link_libraries(${TARGET} PRIVATE ${RDKIT_COMPONENT_TARGET})
    endforeach ()
    foreach (RDKIT_COMPONENT ${param_PUBLIC})
        # string(TOLOWER ${RDKIT_COMPONENT} RDKIT_COMPONENT_TARGET)
        set(RDKIT_COMPONENT_TARGET ${RDKIT_COMPONENT})
        set(RDKIT_COMPONENT_TARGET rdkit_${RDKIT_COMPONENT_TARGET})
        add_dependencies(${TARGET} ${RDKIT_COMPONENT_TARGET})
        target_link_libraries(${TARGET} PUBLIC ${RDKIT_COMPONENT_TARGET})
    endforeach ()
endfunction()

# ncnn
function(xgd_link_ncnn TARGET)
    add_dependencies(${TARGET} ncnn)
    target_link_libraries(${TARGET} PRIVATE ncnn)
endfunction()

# openmp
function(xgd_link_omp TARGET)
    get_target_property(XGD_OMP_TRY_LINKED ${TARGET} XGD_OMP_TRY_LINKED)
    if (XGD_OMP_TRY_LINKED)
        return()
    endif ()
    if (ANDROID)
        target_link_libraries(${TARGET} PRIVATE -static-openmp)
        set_target_properties(${TARGET} PROPERTIES XGD_OMP_LINKED 1)
    elseif (OpenMP_CXX_FOUND)
        target_link_libraries(${TARGET} PRIVATE OpenMP::OpenMP_CXX)
        set_target_properties(${TARGET} PROPERTIES XGD_OMP_LINKED 1)
    else ()
        message(STATUS "openmp: OpenMP_CXX not found for ${TARGET}")
        set_target_properties(${TARGET} PROPERTIES XGD_OMP_LINKED 0)
    endif ()
    set_target_properties(${TARGET} PROPERTIES XGD_OMP_TRY_LINKED 1)
endfunction()

# ggml
function(xgd_link_ggml TARGET)
    add_dependencies(${TARGET} ggml)
    target_link_libraries(${TARGET} PRIVATE ggml)
endfunction()

# ggml-examples
function(xgd_link_ggml_examples TARGET EXAMPLE)
    add_dependencies(${TARGET} ggml_${EXAMPLE})
    target_link_libraries(${TARGET} PRIVATE ggml_${EXAMPLE})
endfunction()

function(xgd_link_ncnn_omp TARGET)
    get_target_property(XGD_OMP_LINKED ${TARGET} XGD_OMP_LINKED)
    if (XGD_OMP_LINKED)
        return()
    endif ()
    if (TARGET ncnn_omp)
        add_dependencies(${TARGET} ncnn_omp)
        target_link_libraries(${TARGET} PRIVATE ncnn_omp)
        message(STATUS "openmp: link ${TARGET} to ncnn simpleomp")
    endif ()
endfunction()

function(xgd_use_header TARGET)
    cmake_parse_arguments(param "" "" "PUBLIC;PRIVATE" ${ARGN})
    macro(xgd_internal_include_header HEADER PUBLIC)
        string(TOLOWER ${HEADER} HEADER_DIR)
        set(HEADER_DIRS)
        if (${HEADER_DIR} STREQUAL "boost")
            set(_BOOST_ALL_COMPONENTS accumulators algorithm align any array asio assert assign atomic beast bimap bind callable_traits chrono circular_buffer compatibility compute concept_check config container_hash container context contract conversion convert core coroutine coroutine2 crc date_time describe detail dll dynamic_bitset endian exception fiber filesystem flyweight foreach format function_types function functional fusion geometry gil graph_parallel graph hana headers heap histogram hof icl integer interprocess intrusive io iostreams iterator json lambda lambda2 leaf lexical_cast local_function locale lockfree log logic math metaparse move mp11 mpi mpl msm multi_array multi_index multiprecision mysql nowide numeric/conversion numeric/interval numeric/odeint numeric/ublas optional outcome parameter_python parameter pfr phoenix poly_collection polygon pool predef preprocessor process program_options property_map_parallel property_map property_tree proto ptr_container python qvm random range ratio rational regex safe_numerics scope_exit serialization signals2 smart_ptr sort spirit stacktrace statechart static_assert static_string stl_interfaces system test thread throw_exception timer tokenizer tti tuple type_erasure type_index type_traits typeof units unordered url utility uuid variant variant2 vmd wave winapi xpressive yap)
            foreach (_BOOST_COMPONENT ${_BOOST_ALL_COMPONENTS})
                list(APPEND HEADER_DIRS ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/boost-src/boost/libs/${_BOOST_COMPONENT}/include)
            endforeach ()
        elseif (${HEADER_DIR} STREQUAL "cutlass")
            list(APPEND HEADER_DIRS ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/cutlass-src/cutlass/include)
            list(APPEND HEADER_DIRS ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/cutlass-src/cutlass/tools/util/include)
        elseif (${HEADER_DIR} STREQUAL "eigen")
            list(APPEND HEADER_DIRS ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/eigen-src/eigen)
        elseif (${HEADER_DIR} STREQUAL "lbfgs")
            list(APPEND HEADER_DIRS ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/lbfgs-src/lbfgs/include)
        elseif (${HEADER_DIR} STREQUAL "rapidjson")
            list(APPEND HEADER_DIRS ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/rapidjson-src/rapidjson/include)
        elseif (${HEADER_DIR} STREQUAL "taskflow")
            list(APPEND HEADER_DIRS ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/taskflow-src/taskflow)
        else ()
            message(FATAL_ERROR "${HEADER_DIR} is not a valid 3rdparty header library")
        endif ()
        if (${PUBLIC})
            target_include_directories(${TARGET} PUBLIC ${HEADER_DIRS})
        else ()
            target_include_directories(${TARGET} PRIVATE ${HEADER_DIRS})
        endif ()
    endmacro()
    macro(xgd_internal_link_header_deps HEADER)
        string(TOLOWER ${HEADER} HEADER_DIR)
        if (${HEADER_DIR} STREQUAL "armadillo")
            target_compile_definitions(${TARGET} PRIVATE ARMA_DONT_USE_LAPACK ARMA_DONT_USE_BLAS)
            xgd_link_omp(${TARGET})
            if (MSVC)
                # enable openmp 3.0, which fix C3016
                target_compile_options(${TARGET} PRIVATE /openmp:llvm)
            endif ()
        elseif (${HEADER_DIR} STREQUAL "boost")
            target_compile_definitions(${TARGET} PRIVATE "_HAS_AUTO_PTR_ETC=0")
        elseif (${HEADER_DIR} STREQUAL "cutlass")
            xgd_link_cuda(${TARGET} PRIVATE cudart)
        elseif (${HEADER_DIR} STREQUAL "eigen")
            target_compile_definitions(${TARGET} PRIVATE EIGEN_USE_THREADS)
            xgd_link_omp(${TARGET})
            xgd_link_threads(${TARGET})
        elseif (${HEADER_DIR} STREQUAL "taskflow")
            xgd_link_threads(${TARGET})
        endif ()
    endmacro()
    foreach (HEADER ${param_PUBLIC})
        xgd_internal_include_header(${HEADER} 1)
    endforeach ()
    foreach (HEADER ${param_PRIVATE})
        xgd_internal_include_header(${HEADER} 0)
    endforeach ()
    foreach (HEADER ${param_PUBLIC} ${param_PRIVATE})
        xgd_internal_link_header_deps(${HEADER})
    endforeach ()
endfunction()

function(xgd_link_cuda TARGET)
    cmake_parse_arguments(param "" "" "PRIVATE;PUBLIC" ${ARGN})
    if (param_PUBLIC)
        target_include_directories(${TARGET} PUBLIC ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES})
    else ()
        target_include_directories(${TARGET} PRIVATE ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES})
    endif ()
    foreach (COMPONENT ${param_PUBLIC})
        target_link_libraries(${TARGET} PUBLIC CUDA::${COMPONENT})
    endforeach ()
    foreach (COMPONENT ${param_PRIVATE})
        target_link_libraries(${TARGET} PRIVATE CUDA::${COMPONENT})
    endforeach ()
endfunction()
