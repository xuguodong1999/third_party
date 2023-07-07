# coordgenlibs
function(xgd_build_coordgen_library)
    set(INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR})
    set(SRC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/coordgen)
    xgd_add_library(
            coordgenlibs
            SRC_DIRS ${SRC_DIR}
            PRIVATE_INCLUDE_DIRS ${SRC_DIR}
            INCLUDE_DIRS ${INC_DIR}
    )
    xgd_link_maeparser(coordgenlibs)
    xgd_generate_export_header(coordgenlibs "coordgenlibs" ".hpp")
endfunction()