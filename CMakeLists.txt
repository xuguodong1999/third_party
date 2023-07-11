cmake_minimum_required(VERSION 3.22)

project(xgd-third_party VERSION 1.0.1 LANGUAGES C CXX)

#if(NOT XXX)
#    include(config.cmake)
#endif()

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
if(NOT APPLE)
    include(cpufeatures-src/build.cmake)
    xgd_build_cpufeatures_library()
endif()
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
# xgd_add_executable(example SRC_FILES example.cpp)

# xgd_add_executable(asio_ssl_server SRC_FILES boost-src/boost/libs/asio/example/cpp11/ssl/server.cpp)
# add_dependencies(asio_ssl_server ssl)
# target_link_libraries(asio_ssl_server PRIVATE ssl)
# xgd_use_header(asio_ssl_server PRIVATE boost)
# xgd_link_boost(asio_ssl_server PRIVATE thread)
# target_compile_definitions(asio_ssl_server PRIVATE _WIN32_WINNT=0x0601)
# if (EMSCRIPTEN)
#     target_compile_definitions(asio_ssl_server PRIVATE BOOST_HAS_PTHREADS)
# endif ()
