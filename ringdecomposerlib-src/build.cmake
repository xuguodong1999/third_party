# ringdecomposerlib
function(xgd_build_ringdecomposerlib_library)
    set(INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/ringdecomposerlib/src/RingDecomposerLib)
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