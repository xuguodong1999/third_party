# yoga
function(xgd_build_yoga_library)
    set(INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/yoga)
    set(SRC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/yoga/yoga)
    xgd_add_library(
            yoga
            SRC_DIRS
            ${SRC_DIR}
            ${SRC_DIR}/internal
            ${SRC_DIR}/event
            INCLUDE_DIRS ${INC_DIR}
    )
    if (WIN32 AND BUILD_SHARED_LIBS)
        target_compile_definitions(yoga PRIVATE _WINDLL)
    endif ()
    target_link_libraries(yoga PRIVATE $<$<BOOL:${ANDROID}>:log>)
endfunction()