# ade
function(xgd_build_ade_library)
    set(ROOT_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/ade/sources/ade)
    set(INC_DIR ${ROOT_DIR}/include)
    set(SRC_DIR ${ROOT_DIR}/source)
    xgd_add_library(ade STATIC SRC_DIRS ${SRC_DIR} INCLUDE_DIRS ${INC_DIR})
endfunction()