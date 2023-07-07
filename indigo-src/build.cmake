# indigo
function(xgd_build_indigo_library)
    set(ROOT_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/indigo)
    set(CORE_LIB_DIR ${ROOT_DIR}/core/indigo-core)
    set(RENDER_LIB_DIR ${ROOT_DIR}/core/render2d)
    set(THIRD_LIB_DIR ${ROOT_DIR}/third_party)
    set(CORE_EXCLUDE_REGEXES "shmem(.*)")
    if (MSVC OR MINGW)
        list(APPEND CORE_EXCLUDE_REGEXES "(.*)posix(.*)")
    else ()
        list(APPEND CORE_EXCLUDE_REGEXES "(.*)win32(.*)")
    endif ()
    xgd_add_library(
            indigo-core
            SRC_DIRS
            ${CORE_LIB_DIR}/common/base_c
            ${CORE_LIB_DIR}/common/base_cpp
            ${CORE_LIB_DIR}/common/gzip
            ${CORE_LIB_DIR}/common/lzw
            ${CORE_LIB_DIR}/common/math
            ${CORE_LIB_DIR}/graph/src
            # ${CORE_LIB_DIR}/layout/patmake
            ${CORE_LIB_DIR}/layout/src
            ${CORE_LIB_DIR}/molecule/src
            ${CORE_LIB_DIR}/reaction/src
            SRC_FILES
            INCLUDE_DIRS ${CORE_LIB_DIR}
            PRIVATE_INCLUDE_DIRS
            ${CORE_LIB_DIR}/common
            ${THIRD_LIB_DIR}/cppcodec
            ${THIRD_LIB_DIR}/object_threadsafe
            EXCLUDE_REGEXES ${CORE_EXCLUDE_REGEXES}
    )
    xgd_add_library(
            indigo-render2d
            STATIC
            SRC_DIRS
            ${RENDER_LIB_DIR}/src
            INCLUDE_DIRS
            ${CORE_LIB_DIR}
            ${RENDER_LIB_DIR}
            PRIVATE_INCLUDE_DIRS
            ${CORE_LIB_DIR}/common
            ${THIRD_LIB_DIR}/object_threadsafe
            ${THIRD_LIB_DIR}/googlefonts
    )
    target_compile_definitions(indigo-render2d PRIVATE "USE_FONT_MANAGER")
    if (EMSCRIPTEN)
        target_compile_definitions(indigo-render2d PRIVATE "RENDER_EMSCRIPTEN")
    endif()

    add_dependencies(indigo-render2d indigo-core)
    target_link_libraries(indigo-render2d PRIVATE indigo-core)

    add_dependencies(indigo-render2d cairo)
    target_link_libraries(indigo-render2d PRIVATE cairo)

    add_dependencies(indigo-render2d freetype)
    target_link_libraries(indigo-render2d PRIVATE freetype)

    add_dependencies(indigo-core tinyxml2)
    target_link_libraries(indigo-core PRIVATE tinyxml2)

    xgd_link_inchi(indigo-core)
    xgd_link_zlib(indigo-core)
    xgd_generate_export_header(indigo-core "indigo_core" ".h")

    xgd_use_header(indigo-core PUBLIC rapidjson)
    xgd_disable_warnings(indigo-core)
    xgd_disable_warnings(indigo-render2d)
endfunction()
