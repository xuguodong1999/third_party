# maeparser
function(xgd_build_maeparser_library)
    set(INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR})
    set(SRC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/maeparser)
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