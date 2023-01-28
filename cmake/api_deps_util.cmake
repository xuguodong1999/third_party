function(xgd_configure_file_copy_only TARGET IN_FILE OUT_FILE)
    configure_file(${IN_FILE} ${OUT_FILE} COPYONLY)
    target_sources(${TARGET} PRIVATE ${OUT_FILE})
endfunction()

# disable compiler warning ! only for 3rdparty libs
function(xgd_disable_warnings TARGET)
    target_compile_options(
            ${TARGET}
            PRIVATE
            # $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:-Wno-deprecated-non-prototype -Wno-parentheses -Wno-comment -Wno-constant-logical-operand -Wno-unsequenced -Wno-pointer-bool-conversion -Wno-unused-value -Wno-switch>
            $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:-w>
            $<$<CXX_COMPILER_ID:MSVC>:/w>
    )
endfunction()

function(xgd_add_global_compiler_flag FLAGS)
    foreach (FLAG ${FLAGS})
        message(STATUS "use ${FLAG}")
        add_compile_options($<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:${FLAG}>)
    endforeach ()
endfunction()

function(xgd_check_compiler_arch)
    include(CheckCXXCompilerFlag)
    while (1)
        if (EMSCRIPTEN)
            set(XGD_ARCH_X86 ON CACHE INTERNAL "")
            break()
        endif ()
        check_cxx_source_compiles("
                #include <${XGD_DEPS_DIR}/boost/src/config/checks/architecture/x86.cpp>
                int main() {}" XGD_ARCH_X86)
        if (XGD_ARCH_X86)
            break()
        endif ()
        check_cxx_source_compiles("
                #include <${XGD_DEPS_DIR}/boost/src/config/checks/architecture/mips.cpp>
                int main() {}" XGD_ARCH_MIPS)
        if (XGD_ARCH_MIPS)
            break()
        endif ()
        check_cxx_source_compiles("
                #include <${XGD_DEPS_DIR}/boost/src/config/checks/architecture/power.cpp>
                int main() {}" XGD_ARCH_POWER)
        if (XGD_ARCH_POWER)
            break()
        endif ()
        check_cxx_source_compiles("
                #include <${XGD_DEPS_DIR}/boost/src/config/checks/architecture/arm.cpp>
                int main() {}" XGD_ARCH_ARM)
        break()
    endwhile ()

    if (XGD_ARCH_ARM)
        check_cxx_source_compiles("
            #include <${XGD_DEPS_DIR}/boost/src/config/checks/architecture/32.cpp>
            int main() {}" XGD_ARCH_ARM32)
        check_cxx_source_compiles("
            #include <${XGD_DEPS_DIR}/boost/src/config/checks/architecture/64.cpp>
            int main() {}" XGD_ARCH_ARM64)
    endif ()

    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        check_cxx_compiler_flag("-march=native" XGD_FLAG_MARCH_NATIVE)
        if (XGD_FLAG_MARCH_NATIVE)
            xgd_add_global_compiler_flag(-march=native)
        endif ()
    endif ()

    if (EMSCRIPTEN)
        check_cxx_compiler_flag("-msimd128" XGD_EMSCRIPTEN_SIMD)
        if (XGD_EMSCRIPTEN_SIMD)
            set(XGD_FLAG_SSE ON CACHE INTERNAL "")
            set(XGD_FLAG_AVX OFF CACHE INTERNAL "")
            set(XGD_FLAG_AVX2 OFF CACHE INTERNAL "")
            xgd_add_global_compiler_flag(-msimd128)
        endif ()
    elseif (XGD_ARCH_X86)
        if (MSVC)
            # /arch:SSE and /arch:SSE2 doesn't work and is enabled by default
            set(XGD_FLAG_SSE ON CACHE INTERNAL "")

            check_cxx_compiler_flag("/arch:AVX" XGD_FLAG_AVX)
            if (XGD_FLAG_AVX)
                xgd_add_global_compiler_flag(/arch:AVX)
            endif ()

            check_cxx_compiler_flag("/arch:AVX2" XGD_FLAG_AVX2)
            if (XGD_FLAG_AVX2)
                xgd_add_global_compiler_flag(/arch:AVX2)
            endif ()
        else ()
            check_cxx_compiler_flag("-mavx" XGD_FLAG_AVX)
            if (XGD_FLAG_AVX)
                xgd_add_global_compiler_flag(-mavx)
            endif ()
            check_cxx_compiler_flag("-mfma -mf16c -mxop -mavx2" XGD_FLAG_AVX2)
            if (XGD_FLAG_AVX2)
                xgd_add_global_compiler_flag(-mfma -mf16c -mxop -mavx2)
            endif ()
            check_cxx_compiler_flag("-msse -msse2" XGD_FLAG_SSE)
            if (XGD_FLAG_SSE)
                xgd_add_global_compiler_flag(-msse -msse2)
            endif ()
        endif ()
    elseif (XGD_ARCH_ARM64)
        set(XGD_FLAG_NEON ON CACHE INTERNAL "")
    endif ()
    if (XGD_FLAG_SSE)
        add_compile_definitions(__SSE__ __SSE2__)
    endif ()
endfunction()

macro(xgd_setup_compile_options)
    # C11
    set(CMAKE_C_STANDARD 11)
    set(CMAKE_C_STANDARD_REQUIRED ON)

    # C++20
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)

    # CUDA C++17
    set(CMAKE_CUDA_STANDARD 17)
    set(CMAKE_CUDA_STANDARD_REQUIRED ON)

    # Export only public symbols
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)

    if (MSVC)
        add_compile_options(
                $<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:/MP> # multi processor build
                $<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:/utf-8> # correct msvc charset
        )
        add_link_options(
                /manifest:no # do not generate manifest
        )
        # for M_PI macro
        add_compile_definitions(_USE_MATH_DEFINES)
        # crt
        # set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    elseif (EMSCRIPTEN)
        set(N 8)
        if (NOT XGD_PRODUCTION_BUILD)
            include(ProcessorCount)
            ProcessorCount(N)
            message(STATUS "cpu procs: ${N}")
            if (N LESS 6)
                set(N 6)
            endif ()
            math(EXPR N "${N}-2")
        endif ()
        add_compile_options(
                -frtti -fexceptions
                -sUSE_PTHREADS=1
        )
        # PTHREAD_POOL_SIZE not work for qt_add_executable
        add_link_options(
                -frtti -fexceptions
                -sUSE_PTHREADS=1 -sPTHREAD_POOL_SIZE=${N}

                -sTOTAL_MEMORY=1024MB
                -sTOTAL_STACK=1MB

                -sSAFE_HEAP=1
                -sASSERTIONS=1
        )
        # FIXME: hack to remove link options from Qt${QT_VERSION_MAJOR}::Platform, and re-add as we need
        # reason: if we just use Qt as a library, global var "createQtAppInstance" will mess up everything
        # it is needed only when we construct a QCoreApplication
        if (TARGET Qt${QT_VERSION_MAJOR}::Platform)
            set_target_properties(Qt${QT_VERSION_MAJOR}::Platform PROPERTIES INTERFACE_LINK_OPTIONS "")
        endif ()
    endif ()
endmacro()

# common library
function(xgd_add_library TARGET)
    # usage
    # xgd_add_library(your-awesome-target SRC_DIRS [...] SRC_FILES [...] INCLUDE_DIRS [...] PRIVATE_INCLUDE_DIRS [...])
    cmake_parse_arguments(
            param
            "STATIC;SHARED"
            ""
            "SRC_DIRS;SRC_FILES;INCLUDE_DIRS;PRIVATE_INCLUDE_DIRS;EXCLUDE_SRC_FILES"
            ${ARGN}
    )
    foreach (SRC_DIR ${param_SRC_DIRS})
        aux_source_directory(${SRC_DIR} ${TARGET}_SOURCES)
    endforeach ()
    list(APPEND ${TARGET}_SOURCES ${param_SRC_FILES})
    foreach (EXCLUDE_SRC_FILE ${param_EXCLUDE_SRC_FILES})
        list(REMOVE_ITEM ${TARGET}_SOURCES ${EXCLUDE_SRC_FILE})
    endforeach ()

    if (param_STATIC)
        add_library(${TARGET} STATIC ${${TARGET}_SOURCES})
    elseif (param_SHARED)
        add_library(${TARGET} SHARED ${${TARGET}_SOURCES})
    else ()
        add_library(${TARGET} ${${TARGET}_SOURCES})
    endif ()
    xgd_lib_apply_release_info(${TARGET})
    target_include_directories(
            ${TARGET}
            PUBLIC ${param_INCLUDE_DIRS}
            PRIVATE ${param_PRIVATE_INCLUDE_DIRS}
    )
    if (XGD_DEBUG_POSTFIX)
        set_target_properties(${TARGET} PROPERTIES DEBUG_POSTFIX ${XGD_DEBUG_POSTFIX})
    endif ()
endfunction()

# global init static library
function(xgd_add_global_init_unit TARGET LIBRARY)
    set(GLOBAL_INIT_SRC ${XGD_DEPS_DIR}/cmake/global_init_source/${LIBRARY}.cpp)
    if (NOT EXISTS ${GLOBAL_INIT_SRC})
        message(FATAL_ERROR "${GLOBAL_INIT_SRC} not exist for target ${LIBRARY}")
    endif ()
    get_target_property(TARGET_TYPE ${TARGET} TYPE)
    get_target_property(IS_JNI_LIB ${TARGET} IS_JNI_LIB)
    if (TARGET_TYPE STREQUAL "EXECUTABLE" OR IS_JNI_LIB)
        target_sources(${TARGET} PRIVATE ${GLOBAL_INIT_SRC})
    endif ()
endfunction()

function(xgd_generate_export_header TARGET BASE_NAME EXT)
    set(EXPORT_HEADER_INCLUDE_DIR ${XGD_GENERATED_DIR}/${BASE_NAME}/include)
    include(GenerateExportHeader)
    generate_export_header(
            ${TARGET}
            BASE_NAME ${BASE_NAME}
            EXPORT_FILE_NAME "${EXPORT_HEADER_INCLUDE_DIR}/${BASE_NAME}_export${EXT}"
    )
    target_include_directories(
            ${TARGET}
            PUBLIC
            ${EXPORT_HEADER_INCLUDE_DIR}
    )
endfunction()

function(xgd_generate_export_header_modules TARGET BASE_NAME MODULE_NAME EXT)
    set(EXPORT_HEADER_INCLUDE_DIR ${XGD_GENERATED_DIR}/${BASE_NAME}/include)
    include(GenerateExportHeader)
    generate_export_header(
            ${TARGET}
            BASE_NAME "${BASE_NAME}_${MODULE_NAME}"
            EXPORT_FILE_NAME
            "${EXPORT_HEADER_INCLUDE_DIR}/${MODULE_NAME}/${BASE_NAME}_export${EXT}"
    )
    target_include_directories(
            ${TARGET}
            PUBLIC
            ${EXPORT_HEADER_INCLUDE_DIR}
    )
endfunction()

function(xgd_lib_apply_release_info TARGET)
    if (NOT XGD_PRODUCTION_BUILD OR NOT EXISTS ${XGD_ASSET_DIR})
        return()
    endif ()
    get_target_property(TARGET_TYPE ${TARGET} TYPE)
    if (WIN32)
        target_sources(${TARGET} PRIVATE ${XGD_ASSET_DIR}/xgd_lib.rc)
    endif ()
endfunction()

# remove unused 3rdparty lib from cmake "all" target
function(xgd_exclude_from_all TARGET)
    cmake_parse_arguments(param "DISABLE" "" "" ${ARGN})
    if (NOT param_DISABLE)
        set_target_properties(${TARGET} PROPERTIES EXCLUDE_FROM_ALL ON)
    else ()
        set_target_properties(${TARGET} PROPERTIES EXCLUDE_FROM_ALL OFF)
    endif ()
endfunction()

function(xgd_generate_text_assets TARGET BASE_NAME)
    cmake_parse_arguments(param "" "" "SRC_FILES" ${ARGN})
    set(ASSET_INC_DIR ${XGD_GENERATED_DIR}/${BASE_NAME}/include)
    set(ASSET_INC_FILE ${ASSET_INC_DIR}/text_assets.hpp)
    set(ASSET_SRC_FILE ${XGD_GENERATED_DIR}/${BASE_NAME}/src/text_assets.cpp)
    set(NEED_UPDATE 0)
    foreach (SRC_FILE ${param_SRC_FILES})
        if (NOT EXISTS ${SRC_FILE})
            message(FATAL_ERROR "generate_text_assets: ${SRC_FILE} not exist")
        endif ()
    endforeach ()
    if (EXISTS ${ASSET_INC_FILE} AND EXISTS ${ASSET_SRC_FILE})
        foreach (SRC_FILE ${param_SRC_FILES})
            if ("${SRC_FILE}" IS_NEWER_THAN "${ASSET_SRC_FILE}")
                set(NEED_UPDATE 1)
                break()
            endif ()
        endforeach ()
    else ()
        set(NEED_UPDATE 1)
    endif ()
    target_include_directories(${TARGET} PRIVATE ${ASSET_INC_DIR})
    if (NOT NEED_UPDATE)
        target_sources(${TARGET} PRIVATE ${ASSET_SRC_FILE})
        return()
    endif ()
    string(TOUPPER ${BASE_NAME} CPP_VARIABLE_NAME)
    set(INC_BUFFER "#include <unordered_map>\n")
    string(APPEND INC_BUFFER "#include <string>\n")
    string(APPEND INC_BUFFER "namespace ${BASE_NAME} {\n")
    string(APPEND INC_BUFFER "extern const std::unordered_map<std::string, std::string> ${CPP_VARIABLE_NAME}_ASSET_MAP;\n")
    string(APPEND INC_BUFFER "}")

    set(SRC_BUFFER "#include \"text_assets.hpp\"\n")
    string(APPEND SRC_BUFFER "using namespace std;\n")
    string(APPEND SRC_BUFFER "const unordered_map<string, string> ${BASE_NAME}::${CPP_VARIABLE_NAME}_ASSET_MAP{\n")
    foreach (SRC_FILE ${param_SRC_FILES})
        get_filename_component(SRC_FILE_NAME ${SRC_FILE} NAME)
        string(APPEND SRC_BUFFER "{R\"(${SRC_FILE_NAME})\",")
        file(READ "${SRC_FILE}" FILE_CONTENT)
        string(REPLACE "\"" "\\\"" FILE_CONTENT ${FILE_CONTENT})
        # for MSVC C2026: split large string to 16kb chunks
        macro(SPLIT_BY_CHUNK)
            math(EXPR CHUNK_SIZE "16*1024-4")
            string(LENGTH ${FILE_CONTENT} FILE_LENGTH)
            set(BEG 0)
            set(CHUNKED_CONTENT "")
            while (${BEG} LESS ${FILE_LENGTH})
                math(EXPR OFFSET "${FILE_LENGTH}-${BEG}+1")
                if (${OFFSET} GREATER ${CHUNK_SIZE})
                    set(OFFSET ${CHUNK_SIZE})
                endif ()
                string(SUBSTRING ${FILE_CONTENT} ${BEG} ${OFFSET} CHUNK_STRING)
                string(APPEND CHUNKED_CONTENT "R\"(${CHUNK_STRING})\" ")
                math(EXPR BEG "${BEG}+${OFFSET}")
            endwhile ()
            string(APPEND SRC_BUFFER "${CHUNKED_CONTENT}},\n")
        endmacro()
        if (MSVC)
            SPLIT_BY_CHUNK()
        else ()
            string(APPEND SRC_BUFFER "R\"(${FILE_CONTENT})\"},\n")
        endif ()
    endforeach ()
    string(APPEND SRC_BUFFER "};")
    file(WRITE ${ASSET_INC_FILE} "${INC_BUFFER}")
    file(WRITE ${ASSET_SRC_FILE} "${SRC_BUFFER}")
    target_sources(${TARGET} PRIVATE ${ASSET_SRC_FILE})
endfunction()
