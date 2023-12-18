project(examples_bgl)

set(ROOT_DIR ${XGD_THIRD_PARTY_DIR}/boost-src/boost/libs/graph/example)

aux_source_directory(${ROOT_DIR} SRC_FILES)

set(SKIP_FILES
        cc-internet.cpp
        dfs-parenthesis.cpp
        edge-connectivity.cpp
        girth.cpp
        kruskal-telephone.cpp
        iohb.c
        leda-concept-check.cpp
        leda-graph-eg.cpp
        labeled_graph.cpp
        loops_dfs.cpp
        miles_span.cpp
        min_max_paths.cpp
        prim-telephone.cpp
        reachable-loop-tail.cpp
        reachable-loop-head.cpp
        roget_components.cpp
        scc.cpp
        topo-sort-with-sgb.cpp
        topo-sort-with-leda.cpp)

function(xgd_link_bgl_examples SRC_FILE_NAME LIB)
    set(TARGET_NAME "${PROJECT_NAME}_${SRC_FILE_NAME}")
    xgd_link_libraries(${TARGET_NAME} PRIVATE ${LIB})
endfunction()

foreach (SRC_FILE ${SRC_FILES})
    get_filename_component(SRC_FILE_NAME_FULL "${SRC_FILE}" NAME)
    if (${SRC_FILE_NAME_FULL} IN_LIST SKIP_FILES)
        continue()
    endif ()

    get_filename_component(SRC_FILE_NAME "${SRC_FILE}" NAME_WE)
    set(TARGET_NAME "${PROJECT_NAME}_${SRC_FILE_NAME}")
    xgd_add_executable(${TARGET_NAME} SRC_FILES ${SRC_FILE})
    xgd_link_libraries(${TARGET_NAME} PRIVATE boost_graph)
endforeach ()

xgd_link_bgl_examples(fr_layout boost_timer)
target_compile_definitions(${PROJECT_NAME}_fr_layout PRIVATE BOOST_TIMER_ENABLE_DEPRECATED)
