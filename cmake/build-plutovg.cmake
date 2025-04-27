# plutovg
set(ROOT_DIR ${XGD_THIRD_PARTY_DIR}/plutovg-src/plutovg)
set(INC_DIR ${ROOT_DIR}/include)
set(SRC_DIR ${ROOT_DIR}/source)
xgd_add_library(plutovg SRC_DIRS ${SRC_DIR} INCLUDE_DIRS ${INC_DIR})

target_compile_definitions(plutovg PRIVATE PLUTOVG_BUILD)
if (NOT BUILD_SHARED_LIBS)
    target_compile_definitions(plutovg PUBLIC PLUTOVG_BUILD_STATIC)
endif ()