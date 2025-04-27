# lunasvg
set(ROOT_DIR ${XGD_THIRD_PARTY_DIR}/lunasvg-src/lunasvg)
set(INC_DIR ${ROOT_DIR}/include)
set(SRC_DIR ${ROOT_DIR}/source)
xgd_add_library(lunasvg SRC_DIRS ${SRC_DIR} INCLUDE_DIRS ${INC_DIR})

target_compile_definitions(lunasvg PRIVATE LUNASVG_BUILD)
if (NOT BUILD_SHARED_LIBS)
    target_compile_definitions(lunasvg PUBLIC LUNASVG_BUILD_STATIC)
endif ()

xgd_link_libraries(lunasvg PRIVATE plutovg)