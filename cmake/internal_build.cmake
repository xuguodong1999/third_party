# yoga
function(xgd_build_yoga_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/yoga-src/yoga)
    set(SRC_DIR ${XGD_DEPS_DIR}/cpp/yoga-src/yoga/yoga)
    xgd_add_library(
            yoga
            SRC_DIRS
            ${SRC_DIR}
            ${SRC_DIR}/internal
            ${SRC_DIR}/event
            INCLUDE_DIRS ${INC_DIR}
    )
    if (WIN32 AND BUILD_SHARED_LIBS)
        target_compile_definitions(yoga PRIVATE _WINDLL)
    endif ()
    target_link_libraries(yoga PRIVATE $<$<BOOL:${ANDROID}>:log>)
endfunction()

# spdlog
function(xgd_build_spdlog_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/spdlog-src/spdlog/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/cpp/spdlog-src/spdlog/src)
    xgd_add_library(
            spdlog
            SRC_DIRS ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
    )
    target_compile_definitions(spdlog PUBLIC SPDLOG_COMPILED_LIB)
    if (BUILD_SHARED_LIBS)
        target_compile_definitions(
                spdlog
                PRIVATE SPDLOG_SHARED_LIB FMT_EXPORT
                PUBLIC FMT_SHARED
        )
    endif ()
    xgd_link_threads(spdlog)
    target_link_libraries(spdlog PUBLIC $<$<BOOL:${ANDROID}>:log>)
endfunction()

# gtest
function(xgd_build_gtest_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/gtest-src/gtest/googletest/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/cpp/gtest-src/gtest/googletest/src)
    xgd_add_library(
            gtest
            SRC_FILES ${SRC_DIR}/gtest-all.cc
            INCLUDE_DIRS ${INC_DIR}
            PRIVATE_INCLUDE_DIRS ${SRC_DIR}/..
    )
    if (BUILD_SHARED_LIBS)
        target_compile_definitions(
                gtest
                PRIVATE "GTEST_CREATE_SHARED_LIBRARY=1"
        )
    endif ()
    xgd_link_threads(gtest)
endfunction()

# benchmark
function(xgd_build_benchmark_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/benchmark-src/benchmark/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/cpp/benchmark-src/benchmark/src)
    xgd_add_library(
            benchmark
            SRC_DIRS ${SRC_DIR} ${SRC_DIR}/src
            INCLUDE_DIRS ${INC_DIR}
            EXCLUDE_SRC_FILES ${SRC_DIR}/benchmark_main.cc
    )
    target_compile_definitions(
            benchmark
            PRIVATE benchmark_EXPORTS
    )
    if (NOT BUILD_SHARED_LIBS)
        target_compile_definitions(
                benchmark
                PUBLIC BENCHMARK_STATIC_DEFINE
        )
    endif ()
    xgd_link_threads(benchmark)
endfunction()

# zlib
function(xgd_build_zlib_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/zlib-src/zlib)
    set(SRC_DIR ${XGD_DEPS_DIR}/cpp/zlib-src/zlib)
    xgd_add_library(
            zlib
            SRC_DIRS ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
    )
    target_compile_definitions(zlib PRIVATE ZLIB_DLL)

    # zlib uses extern to declare functions
    xgd_disable_warnings(zlib)
endfunction()

# inchi
function(xgd_build_inchi_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/inchi-src/inchi/INCHI_BASE/src)
    set(SRC_DIR ${INC_DIR})
    set(API_SRC_DIR ${XGD_DEPS_DIR}/cpp/inchi-src/inchi/INCHI_API/libinchi/src)
    xgd_add_library(
            inchi
            SRC_DIRS ${SRC_DIR} ${API_SRC_DIR} ${API_SRC_DIR}/ixa
            PRIVATE_INCLUDE_DIRS ${SRC_DIR}/ixa ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
    )
    xgd_generate_export_header(inchi "inchi" ".h")
    target_compile_definitions(inchi PRIVATE TARGET_API_LIB)
    xgd_disable_warnings(inchi)
endfunction()

# maeparser
function(xgd_build_maeparser_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/maeparser-src)
    set(SRC_DIR ${XGD_DEPS_DIR}/cpp/maeparser-src/maeparser)
    xgd_add_library(
            maeparser
            SRC_DIRS ${SRC_DIR}
            PRIVATE_INCLUDE_DIRS ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
    )
    xgd_link_boost(maeparser PRIVATE iostreams)
    xgd_use_header(maeparser PUBLIC boost)
    xgd_generate_export_header(maeparser "maeparser" ".hpp")
endfunction()

# coordgenlibs
function(xgd_build_coordgenlibs_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/coordgen-src)
    set(SRC_DIR ${XGD_DEPS_DIR}/cpp/coordgen-src/coordgen)
    xgd_add_library(
            coordgenlibs
            SRC_DIRS ${SRC_DIR}
            PRIVATE_INCLUDE_DIRS ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
    )
    xgd_link_maeparser(coordgenlibs)
    xgd_generate_export_header(coordgenlibs "coordgenlibs" ".hpp")
endfunction()


# yaehmop
function(xgd_build_yaehmop_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/yaehmop-src)
    set(SRC_DIR ${XGD_DEPS_DIR}/cpp/yaehmop-src/yaehmop/tightbind)
    xgd_add_library(
            yaehmop
            STATIC # yaehmop has no export header preparation
            SRC_DIRS
            ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
            PRIVATE_INCLUDE_DIRS ${SRC_DIR}
            EXCLUDE_SRC_FILES
            ${SRC_DIR}/test_driver.c
            ${SRC_DIR}/main.c
    )
    target_compile_definitions(yaehmop PUBLIC UNDERSCORE_FORTRAN PRIVATE NEED_DSIGN)
    xgd_disable_warnings(yaehmop)
endfunction()

# avalontoolkit
function(xgd_build_avalontoolkit_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/avalontoolkit-src/avalontoolkit/SourceDistribution/common)
    set(SRC_DIR ${INC_DIR})
    xgd_add_library(
            avalontoolkit
            STATIC # avalontoolkit has no export header preparation
            SRC_DIRS
            ${SRC_DIR}
            INCLUDE_DIRS
            ${INC_DIR}
            EXCLUDE_REGEXES
            "^(.*)test(.*)\\.c"
    )
    xgd_disable_warnings(avalontoolkit)
endfunction()

# ringdecomposerlib
function(xgd_build_ringdecomposerlib_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/ringdecomposerlib-src/ringdecomposerlib/src/RingDecomposerLib)
    set(SRC_DIR ${INC_DIR})
    xgd_add_library(
            ringdecomposerlib
            SRC_DIRS
            ${SRC_DIR}
            INCLUDE_DIRS
            ${INC_DIR}
            EXCLUDE_SRC_FILES
            ${SRC_DIR}/example.c
            ${SRC_DIR}/main.cc
    )
    xgd_generate_export_header(ringdecomposerlib "ringdecomposerlib" ".h")
endfunction()

# freesasa
function(xgd_build_freesasa_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/freesasa-src/freesasa/src)
    set(SRC_DIR ${INC_DIR})
    xgd_add_library(
            freesasa
            STATIC # freesasa has no export header preparation
            SRC_DIRS
            ${SRC_DIR}
            INCLUDE_DIRS
            ${INC_DIR}
            EXCLUDE_SRC_FILES
            ${SRC_DIR}/cif.cc
            ${SRC_DIR}/example.c
            ${SRC_DIR}/json.c
            ${SRC_DIR}/main.cc
    )
    xgd_link_xml2(freesasa)
    xgd_disable_warnings(freesasa)
endfunction()
