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
            boost_array
            boost_numeric_odeint)
endforeach ()

