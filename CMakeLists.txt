cmake_minimum_required(VERSION 3.26)

project(xgd-external VERSION 1.0.1 LANGUAGES C CXX)

find_package(Threads REQUIRED)

# system libraries
option(XGD_USE_OPENMP "" ON)
option(XGD_USE_CUDA "" ON)
option(XGD_USE_QT "" ON)
option(XGD_USE_VK "" ON)
option(XGD_USE_TORCH "" ON)
option(XGD_USE_CCACHE "" ON)

# platform related optimization
option(XGD_OPT_ARCH_X86 "" ON)
option(XGD_OPT_ARCH_ARM "" ON)
option(XGD_OPT_ARCH_MIPS "" ON)
option(XGD_OPT_ARCH_POWER "" ON)
option(XGD_OPT_ARCH_32 "" ON)
option(XGD_OPT_ARCH_64 "" ON)

option(XGD_FLAG_NEON "" ON)
option(XGD_FLAG_FMA "" ON)
option(XGD_FLAG_F16C "" ON)
option(XGD_FLAG_XOP "" ON)
option(XGD_FLAG_SSE_ALL "" ON)
option(XGD_FLAG_AVX "" ON)
option(XGD_FLAG_AVX2 "" ON)

option(XGD_FLAG_MARCH_NATIVE "" ON)
option(XGD_FLAG_WASM_SIMD128 "" ON)

# detailed project config
option(XGD_BUILD_WITH_GRADLE "" OFF)
option(XGD_NO_DEBUG_CONSOLE "" ON)

if (NOT DEFINED XGD_WINE64_RUNTIME)
    set(XGD_WINE64_RUNTIME "" CACHE FILEPATH "path to wine64")
endif ()
if (NOT DEFINED XGD_NODEJS_RUNTIME)
    set(XGD_NODEJS_RUNTIME "" CACHE FILEPATH "path to node")
endif ()
if (NOT DEFINED XGD_POSTFIX)
    set(XGD_POSTFIX "" CACHE STRING "param passed to CMAKE_DEBUG_POSTFIX")
endif ()
if (NOT DEFINED XGD_WASM_ENV)
    set(XGD_WASM_ENV "" CACHE STRING "param passed to -sENVIRONMENT")
endif ()
if (NOT DEFINED XGD_QT_MODULES)
    set(XGD_QT_MODULES "Core;Gui;Qml;OpenGL;Widgets;Test;Core5Compat;Concurrent" CACHE STRING "")
endif ()
if (NOT DEFINED XGD_QT_MODULES)
    set(XGD_OPTIONAL_QT_MODULES "Multimedia;MultimediaWidgets;3DCore;3DExtras" CACHE STRING "")
endif ()

# directory layout
if (NOT XGD_BUILD_WITH_GRADLE) # gradle relies on directory layout to copy libraries
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
endif ()

include(build.cmake)

# find system packages
xgd_external_find_package()

# find system runtimes
xgd_external_find_runtime()

# check supported compiler flags, link options, etc.
xgd_external_check_env()

enable_testing()
#
include(ade-src/build.cmake)
xgd_build_ade_library()
#
include(abseil-src/build.cmake)
xgd_build_abseil_library()
#
include(avalontoolkit-src/build.cmake)
xgd_build_avalontoolkit_library()
#
include(benchmark-src/build.cmake)
xgd_build_benchmark_library()
#
include(boost-src/build.cmake)
xgd_build_boost_library()
#
include(cairo-src/build.cmake)
xgd_build_cairo_library()
#
include(cpufeatures-src/build.cmake)
xgd_build_cpufeatures_library()
#
include(coordgen-src/build.cmake)
xgd_build_coordgen_library()
#
include(freetype-src/build.cmake)
xgd_build_freetype_library()
#
include(freesasa-src/build.cmake)
xgd_build_freesasa_library()
#
include(ggml-src/build.cmake)
xgd_build_ggml_library()
#
include(gtest-src/build.cmake)
xgd_build_gtest_library()
#
include(inchi-src/build.cmake)
xgd_build_inchi_library()
#
include(indigo-src/build.cmake)
xgd_build_indigo_library()
#
include(libpng-src/build.cmake)
xgd_build_libpng_library()
#
include(libxml2-src/build.cmake)
xgd_build_libxml2_library()
#
include(maeparser-src/build.cmake)
xgd_build_maeparser_library()
#
include(ncnn-src/build.cmake)
xgd_build_ncnn_library()
#
if (XGD_USE_QT)
    include(nodeeditor-src/build.cmake)
    xgd_build_nodeeditor_library()
endif ()
#
include(openbabel-src/build.cmake)
xgd_build_openbabel_library()
#
include(opencv-src/build.cmake)
xgd_build_opencv_library()
#
include(openssl-src/build.cmake)
xgd_build_openssl_library()
#
include(pixman-src/build.cmake)
xgd_build_pixman_library()
#
include(protobuf-src/build.cmake)
xgd_build_protobuf_library()
#
include(rdkit-src/build.cmake)
xgd_build_rdkit_library()
#
include(ringdecomposerlib-src/build.cmake)
xgd_build_ringdecomposerlib_library()
#
include(spdlog-src/build.cmake)
xgd_build_spdlog_library()
#
include(tinyxml2-src/build.cmake)
xgd_build_tinyxml2_library()
#
include(yaehmop-src/build.cmake)
xgd_build_yaehmop_library()
#
include(yoga-src/build.cmake)
xgd_build_yoga_library()
#
include(zlib-src/build.cmake)
xgd_build_zlib_library()
#
add_executable(example example.cpp)

add_executable(asio_ssl_server boost-src/boost/libs/asio/example/cpp11/ssl/server.cpp)
add_dependencies(asio_ssl_server ssl)
target_link_libraries(asio_ssl_server PRIVATE ssl)
xgd_use_header(asio_ssl_server PRIVATE boost)
xgd_link_boost(asio_ssl_server PRIVATE thread)
target_compile_definitions(asio_ssl_server PRIVATE _WIN32_WINNT=0x0601)
if (EMSCRIPTEN)
    target_compile_definitions(asio_ssl_server PRIVATE BOOST_HAS_PTHREADS)
endif ()
