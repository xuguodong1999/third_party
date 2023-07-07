# avalontoolkit
function(xgd_build_avalontoolkit_library)
    set(INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/avalontoolkit/SourceDistribution/common)
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