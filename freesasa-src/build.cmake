# freesasa
function(xgd_build_freesasa_library)
    set(INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/freesasa/src)
    set(SRC_DIR ${INC_DIR})
    xgd_add_library(
            freesasa
            STATIC # freesasa has no export header preparation
            SRC_DIRS
            ${SRC_DIR}
            INCLUDE_DIRS
            ${INC_DIR}
            EXCLUDE_SRC_FILES
            ${SRC_DIR}/cif.cc
            ${SRC_DIR}/example.c
            ${SRC_DIR}/json.c
            ${SRC_DIR}/main.cc
    )
    xgd_link_xml2(freesasa)
    xgd_disable_warnings(freesasa)
endfunction()