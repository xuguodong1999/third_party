include(CheckCXXCompilerFlag)
include(CheckIncludeFiles)
include(CheckSymbolExists)
include(CheckFunctionExists)

set(_XGD_BOOST_DIR ${XGD_EXTERNAL_DIR}/cpp/boost-src/boost/libs)
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
        XGD_USE_OPENCV
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
