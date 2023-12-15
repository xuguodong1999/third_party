cmake_minimum_required(VERSION 3.22)

project(xgd-third_party VERSION 1.0.1 LANGUAGES C CXX)

set(XGD_THIRD_PARTY_DIR ${CMAKE_CURRENT_SOURCE_DIR})

include(cmake/cmake-utils.cmake)
include(cmake/project-config.cmake)

add_subdirectory(shadow_build)
add_subdirectory(${XGD_THIRD_PARTY_DIR}/fluentui-src/fluentui/src/Qt6)
