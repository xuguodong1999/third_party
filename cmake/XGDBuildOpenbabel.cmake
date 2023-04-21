# openbabel
function(xgd_build_openbabel_library)
    set(OB_INC_DIR ${XGD_EXTERNAL_DIR}/cpp/openbabel-src/openbabel/include)
    set(OB_SRC_DIR ${XGD_EXTERNAL_DIR}/cpp/openbabel-src/openbabel/src)
    set(OB_DATA_DIR ${XGD_EXTERNAL_DIR}/cpp/openbabel-src/openbabel/data)
    xgd_add_library(
            openbabel
            SRC_DIRS
            ${OB_SRC_DIR}
            ${OB_SRC_DIR}/charges
            ${OB_SRC_DIR}/descriptors
            ${OB_SRC_DIR}/forcefields
            ${OB_SRC_DIR}/ops
            ${OB_SRC_DIR}/depict
            ${OB_SRC_DIR}/fingerprints
            ${OB_SRC_DIR}/formats
            ${OB_SRC_DIR}/formats/json
            ${OB_SRC_DIR}/formats/xml
            ${OB_SRC_DIR}/math
            ${OB_SRC_DIR}/stereo
            EXCLUDE_SRC_FILES
            ${OB_SRC_DIR}/dlhandler_unix.cpp
            ${OB_SRC_DIR}/dlhandler_win32.cpp
            ${OB_SRC_DIR}/snprintf.c
            ${OB_SRC_DIR}/formats/png2format.cpp
            ${OB_SRC_DIR}/formats/xtcformat.cpp
            ${OB_SRC_DIR}/formats/exampleformat.cpp
            ${OB_SRC_DIR}/depict/cairopainter.cpp
            INCLUDE_DIRS ${OB_INC_DIR}
    )

    xgd_use_header(openbabel PUBLIC eigen PRIVATE rapidjson lbfgs)
    xgd_link_omp(openbabel)

    xgd_link_zlib(openbabel)
    xgd_link_xml2(openbabel)
    xgd_link_inchi(openbabel)
    xgd_link_maeparser(openbabel)
    xgd_link_rdkit(openbabel PRIVATE Depictor GraphMol RDGeometryLib)

    xgd_generate_export_header(openbabel "openbabel" ".hpp")

    include(CheckIncludeFile)
    include(CheckSymbolExists)
    check_include_file(sys/time.h HAVE_SYS_TIME_H)
    check_include_file(rpc/xdr.h HAVE_RPC_XDR_H)
    check_symbol_exists(rint "math.h" HAVE_RINT)
    check_symbol_exists(snprintf "stdio.h" HAVE_SNPRINTF)
    check_symbol_exists(sranddev "stdlib.h" HAVE_SRANDDEV)
    check_symbol_exists(strcasecmp "string.h" HAVE_STRCASECMP)
    check_symbol_exists(strncasecmp "string.h" HAVE_STRNCASECMP)
    set(HAVE_CONIO_H OFF)
    set(HAVE_STATIC_LIBXML ON)
    set(HAVE_STRINGS_H ON)
    set(HAVE_TIME_H ON)
    set(HAVE_REGEX_H ON)
    set(HAVE_SHARED_POINTER ON)
    set(HAVE_EIGEN ON)
    set(HAVE_EIGEN3 ON)
    set(HAVE_STATIC_INCHI ON)
    set(HAVE_LIBZ ON)
    set(HAVE_SSTREAM ON)
    set(HAVE_CLOCK_T ON)
    set(OB_SHARED_PTR_HEADER "memory")
    set(OB_SHARED_PTR_IMPLEMENTATION "std::shared_ptr")
    configure_file(
            ${OB_SRC_DIR}/config.h.cmake
            ${XGD_GENERATED_DIR}/openbabel/include/openbabel/babelconfig.h
    )
    target_include_directories(openbabel PUBLIC ${XGD_GENERATED_DIR}/openbabel/include)
    if (HAVE_RPC_XDR_H)
        target_sources(openbabel PRIVATE ${OB_SRC_DIR}/formats/xtcformat.cpp)
    endif ()

    file(GLOB_RECURSE OB_DATA_FILES ${OB_DATA_DIR}/*)
    xgd_generate_text_assets(openbabel openbabel SRC_FILES ${OB_DATA_FILES})

    target_compile_options(
            openbabel PRIVATE
            $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:-Wno-switch>
    )
endfunction()
