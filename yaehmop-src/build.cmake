# yaehmop
function(xgd_build_yaehmop_library)
    set(INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR})
    set(SRC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/yaehmop/tightbind)
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