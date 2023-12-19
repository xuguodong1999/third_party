project(examples_odeint)

set(ROOT_DIR ${XGD_THIRD_PARTY_DIR}/boost-src/boost/libs/numeric/odeint/examples)

aux_source_directory(${ROOT_DIR} SRC_FILES)

set(SKIP_FILES)

foreach (SRC_FILE ${SRC_FILES})
    get_filename_component(SRC_FILE_NAME_FULL "${SRC_FILE}" NAME)
    if (${SRC_FILE_NAME_FULL} IN_LIST SKIP_FILES)
        continue()
    endif ()

    get_filename_component(SRC_FILE_NAME "${SRC_FILE}" NAME_WE)
    set(TARGET_NAME "${PROJECT_NAME}_${SRC_FILE_NAME}")
    xgd_add_executable(${TARGET_NAME} SRC_FILES ${SRC_FILE})
    xgd_link_libraries(${TARGET_NAME} PRIVATE
            boost_array
            boost_numeric_odeint)
endforeach ()

function(xgd_add_third_party_example_by_files_in_dir)
    # specify SRC_DIR, ignore SKIP_FILES, each file in SRC_DIR makes an executable
    cmake_parse_arguments(param "" "SRC_DIR" "SKIP_FILES" ${ARGN})
    aux_source_directory(${param_SRC_DIR} SRC_FILES)
    foreach (SRC_FILE ${SRC_FILES})
        get_filename_component(SRC_FILE_NAME_FULL "${SRC_FILE}" NAME)
        if (${SRC_FILE_NAME_FULL} IN_LIST param_SKIP_FILES)
            continue()
        endif ()

        get_filename_component(SRC_FILE_NAME "${SRC_FILE}" NAME_WE)
        set(TARGET_NAME "${PROJECT_NAME}_${SRC_FILE_NAME}")
        xgd_add_executable(${TARGET_NAME} SRC_FILES ${SRC_FILE})
        xgd_link_libraries(${TARGET_NAME} PRIVATE
                boost_array
                boost_numeric_odeint)
    endforeach ()
endfunction()

function(xgd_add_third_party_example_by_dirs_in_dir)
    # specify SRC_DIR, ignore SKIP_FILES, each file in SRC_DIR makes an executable
    cmake_parse_arguments(param "" "ROOT" "SRC_DIRS;SKIP_DIRS" ${ARGN})
endfunction()

