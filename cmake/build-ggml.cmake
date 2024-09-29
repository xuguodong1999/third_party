# ggml
set(ROOT_DIR ${XGD_THIRD_PARTY_DIR}/ggml-src/ggml)
set(INC_DIR ${ROOT_DIR}/include)
set(SRC_DIR ${ROOT_DIR}/src)
set(GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/ggml)
set(GGML_SOURCES ${SRC_DIR}/ggml.c
        ${SRC_DIR}/ggml-alloc.c
        ${SRC_DIR}/ggml-backend.c
        ${SRC_DIR}/ggml-quants.c)

if (XGD_USE_CUDA)
    xgd_add_library(ggml-cuda
            STATIC
            SRC_DIRS ${SRC_DIR}/ggml-cuda ${SRC_DIR}/ggml-cuda/template-instances
            SRC_FILES ${SRC_DIR}/ggml-cuda.cu
            INCLUDE_DIRS ${INC_DIR} ${INC_DIR}/ggm ${SRC_DIR} ${SRC_DIR}/ggml-cuda ${GEN_DIR}/include
    )
    target_compile_definitions(ggml-cuda PRIVATE
            GGML_CUDA_FA_ALL_QUANTS
            GGML_CUDA_USE_GRAPHS
            GGML_CUDA_F16
            PUBLIC GGML_USE_CUDA)
    xgd_link_cuda(ggml-cuda PRIVATE cudart cublas cublasLt cuda_driver)
endif ()

if (APPLE)
    find_library(FOUNDATION_LIBRARY Foundation REQUIRED)
    find_library(METAL_FRAMEWORK Metal REQUIRED)
    find_library(METALKIT_FRAMEWORK MetalKit REQUIRED)

    list(APPEND GGML_SOURCES ${SRC_DIR}/ggml-metal.m)

    # copy ggml-common.h and ggml-metal.metal to bin directory
    configure_file(${SRC_DIR}/ggml-common.h ${GEN_DIR}/ggml-common.h COPYONLY)
    configure_file(${SRC_DIR}/ggml-metal.metal ${GEN_DIR}/ggml-metal.metal COPYONLY)

    set(METALLIB_PATH ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/default.metallib)
    add_custom_command(
            OUTPUT ${METALLIB_PATH}
            COMMAND xcrun -sdk macosx metal -O3 -c ${GEN_DIR}/ggml-metal.metal -o ${GEN_DIR}/ggml-metal.air
            COMMAND xcrun -sdk macosx metallib ${GEN_DIR}/ggml-metal.air -o ${METALLIB_PATH}
            DEPENDS ${SRC_DIR}/ggml-metal.metal ${SRC_DIR}/ggml-common.h
            COMMENT "Compiling Metal kernels"
    )
    add_custom_target(ggml-metal ALL DEPENDS ${METALLIB_PATH})
endif ()

xgd_add_library(
        ggml
        SRC_FILES ${GGML_SOURCES}
        PRIVATE_INCLUDE_DIRS ${INC_DIR}/ggml ${SRC_DIR}
        INCLUDE_DIRS ${INC_DIR} ${GEN_DIR}/include
)
xgd_generate_export_header(ggml "ggml" ".h")
xgd_link_threads(ggml PUBLIC)
target_compile_definitions(ggml PRIVATE "_GNU_SOURCE=1")


if (XGD_USE_CUDA)
    xgd_link_libraries(ggml PRIVATE ggml-cuda)
elseif (APPLE)
    add_dependencies(ggml ggml-metal)
    target_compile_definitions(ggml PUBLIC GGML_METAL_NDEBUG GGML_USE_METAL)
    target_link_libraries(ggml PRIVATE ${FOUNDATION_LIBRARY} ${METAL_FRAMEWORK} ${METALKIT_FRAMEWORK})
endif ()
