# gtest
function(xgd_build_gtest_library)
    set(_GTEST_INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/gtest/googletest/include)
    set(_GTEST_SRC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/gtest/googletest/src)
    set(_GMOCK_INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/gtest/googlemock/include)
    set(_GMOCK_SRC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/gtest/googlemock/src)
    xgd_add_library(
            gtest
            SRC_FILES ${_GTEST_SRC_DIR}/gtest-all.cc ${_GMOCK_SRC_DIR}/gmock-all.cc
            INCLUDE_DIRS ${_GTEST_INC_DIR} ${_GMOCK_INC_DIR}
            PRIVATE_INCLUDE_DIRS ${_GTEST_SRC_DIR}/.. ${_GMOCK_SRC_DIR}/..
    )
    if (BUILD_SHARED_LIBS)
        target_compile_definitions(gtest PRIVATE "GTEST_CREATE_SHARED_LIBRARY=1")
    endif ()
    xgd_link_threads(gtest)
    xgd_add_library(
            gtest_main
            STATIC
            SRC_FILES ${_GTEST_SRC_DIR}/gtest_main.cc
    )
    xgd_link_gtest(gtest_main GTEST DONT_ADD_TEST)
    xgd_add_library(
            gmock_main
            STATIC
            SRC_FILES ${_GMOCK_SRC_DIR}/gmock_main.cc
    )
    xgd_link_gtest(gmock_main GTEST DONT_ADD_TEST)
endfunction()