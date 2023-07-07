# benchmark
function(xgd_build_benchmark_library)
    set(INC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/benchmark/include)
    set(SRC_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/benchmark/src)
    xgd_add_library(
            benchmark
            SRC_DIRS ${SRC_DIR} ${SRC_DIR}/src
            INCLUDE_DIRS ${INC_DIR}
            EXCLUDE_SRC_FILES ${SRC_DIR}/benchmark_main.cc
    )
    target_compile_definitions(
            benchmark
            PRIVATE benchmark_EXPORTS
    )
    if (NOT BUILD_SHARED_LIBS)
        target_compile_definitions(benchmark PUBLIC BENCHMARK_STATIC_DEFINE)
    endif ()
    if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
        target_link_libraries(benchmark PRIVATE shlwapi)
    endif()
    xgd_link_threads(benchmark)
    xgd_add_library(
            benchmark_main
            STATIC
            SRC_FILES ${SRC_DIR}/benchmark_main.cc
            PRIVATE_INCLUDE_DIRS ${INC_DIR}
    )
    xgd_link_benchmark(benchmark_main)
endfunction()