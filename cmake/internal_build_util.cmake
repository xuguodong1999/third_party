# yoga
function(xgd_build_yoga_library)
    set(INC_DIR ${XGD_DEPS_DIR}/yoga/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/yoga/src)
    xgd_add_library(
            yoga
            SRC_DIRS
            ${SRC_DIR}
            ${SRC_DIR}/internal
            ${SRC_DIR}/event
            INCLUDE_DIRS ${INC_DIR}
            PRIVATE_INCLUDE_DIRS ${INC_DIR}/yoga
    )
    if (WIN32 AND BUILD_SHARED_LIBS)
        target_compile_definitions(yoga PRIVATE _WINDLL)
    endif ()
    target_link_libraries(yoga PRIVATE $<$<BOOL:${ANDROID}>:log>)
endfunction()

# spdlog
function(xgd_build_spdlog_library)
    set(INC_DIR ${XGD_DEPS_DIR}/spdlog/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/spdlog/src)
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
    set(INC_DIR ${XGD_DEPS_DIR}/gtest/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/gtest/src)
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
    set(INC_DIR ${XGD_DEPS_DIR}/benchmark/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/benchmark/src)
    xgd_add_library(
            benchmark
            SRC_DIRS ${SRC_DIR} ${SRC_DIR}/src
            INCLUDE_DIRS ${INC_DIR}
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
    set(INC_DIR ${XGD_DEPS_DIR}/zlib/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/zlib/src)
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
    set(INC_DIR ${XGD_DEPS_DIR}/inchi/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/inchi/src)
    xgd_add_library(
            inchi
            SRC_DIRS ${SRC_DIR} ${SRC_DIR}/ixa
            PRIVATE_INCLUDE_DIRS ${SRC_DIR}/ixa ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
    )
    xgd_generate_export_header(inchi "inchi" ".h")
    target_compile_definitions(inchi PRIVATE TARGET_API_LIB)
    xgd_disable_warnings(inchi)
endfunction()

# maeparser
function(xgd_build_maeparser_library)
    set(INC_DIR ${XGD_DEPS_DIR}/maeparser/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/maeparser/src)
    xgd_add_library(
            maeparser
            SRC_DIRS ${SRC_DIR}
            PRIVATE_INCLUDE_DIRS ${INC_DIR}/maeparser
            INCLUDE_DIRS ${INC_DIR}
    )
    xgd_link_boost(maeparser PRIVATE iostreams)
    xgd_use_header(maeparser PUBLIC boost)
    xgd_generate_export_header(maeparser "maeparser" ".hpp")
endfunction()

# coordgenlibs
function(xgd_build_coordgenlibs_library)
    set(INC_DIR ${XGD_DEPS_DIR}/coordgenlibs/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/coordgenlibs/src)
    xgd_add_library(
            coordgenlibs
            SRC_DIRS ${SRC_DIR}
            PRIVATE_INCLUDE_DIRS ${INC_DIR}/coordgen
            INCLUDE_DIRS ${INC_DIR}
    )
    xgd_link_maeparser(coordgenlibs)
    xgd_generate_export_header(coordgenlibs "coordgenlibs" ".hpp")
endfunction()


# yaehmop
function(xgd_build_yaehmop_library)
    set(INC_DIR ${XGD_DEPS_DIR}/yaehmop/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/yaehmop/src)
    xgd_add_library(
            yaehmop
            STATIC # yaehmop has no export header preparation
            SRC_DIRS
            ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
            PRIVATE_INCLUDE_DIRS ${INC_DIR}/yaehmop/tightbind
    )
    target_compile_definitions(yaehmop PUBLIC UNDERSCORE_FORTRAN PRIVATE NEED_DSIGN)
    xgd_disable_warnings(yaehmop)
endfunction()

# avalontoolkit
function(xgd_build_avalontoolkit_library)
    set(INC_DIR ${XGD_DEPS_DIR}/avalontoolkit/include/avalontoolkit)
    set(SRC_DIR ${XGD_DEPS_DIR}/avalontoolkit/src)
    xgd_add_library(
            avalontoolkit
            STATIC # avalontoolkit has no export header preparation
            SRC_DIRS
            ${SRC_DIR}
            INCLUDE_DIRS
            ${INC_DIR}
    )
    xgd_disable_warnings(avalontoolkit)
endfunction()

# ringdecomposerlib
function(xgd_build_ringdecomposerlib_library)
    set(INC_DIR ${XGD_DEPS_DIR}/ringdecomposerlib/include/RingDecomposerLib)
    set(SRC_DIR ${XGD_DEPS_DIR}/ringdecomposerlib/src)
    xgd_add_library(
            ringdecomposerlib
            SRC_DIRS
            ${SRC_DIR}
            INCLUDE_DIRS
            ${INC_DIR}
    )
    xgd_generate_export_header(ringdecomposerlib "ringdecomposerlib" ".h")
endfunction()

# freesasa
function(xgd_build_freesasa_library)
    set(INC_DIR ${XGD_DEPS_DIR}/freesasa/include/freesasa)
    set(SRC_DIR ${XGD_DEPS_DIR}/freesasa/src)
    xgd_add_library(
            freesasa
            STATIC # freesasa has no export header preparation
            SRC_DIRS
            ${SRC_DIR}
            INCLUDE_DIRS
            ${INC_DIR}
    )
    xgd_disable_warnings(freesasa)
endfunction()
