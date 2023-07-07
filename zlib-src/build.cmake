# zlib
function(xgd_build_zlib_library)
    set(INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/zlib)
    set(SRC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/zlib)
    xgd_add_library(
            zlib
            SRC_DIRS ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
    )
    if (BUILD_SHARED_LIBS)
        target_compile_definitions(zlib PRIVATE ZLIB_DLL)
    endif ()
    # zlib uses extern to declare functions
    xgd_disable_warnings(zlib)
endfunction()
