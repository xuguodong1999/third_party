function(xgd_configure_file_copy_only TARGET IN_FILE OUT_FILE)
    configure_file(${IN_FILE} ${OUT_FILE} COPYONLY)
    target_sources(${TARGET} PRIVATE ${OUT_FILE})
endfunction()

# disable compiler warning ! only for 3rdparty libs
function(xgd_disable_warnings TARGET)
    target_compile_options(
            ${TARGET}
            PRIVATE
            $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:-w>
            $<$<CXX_COMPILER_ID:MSVC>:/w>
    )
endfunction()

function(xgd_target_global_options TARGET)
    cmake_parse_arguments(param "" "CXX_STANDARD" "" ${ARGN})
    set(_XGD_COMPILE_OPTIONS "")
    set(_XGD_COMPILE_DEFINITIONS "")
    set(_XGD_LINK_OPTIONS "")
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        # _GLIBCXX_USE_CXX11_ABI=1
        list(APPEND _XGD_COMPILE_OPTIONS -Werror=return-type)
    endif ()
    if (WIN32)
        list(APPEND _XGD_COMPILE_DEFINITIONS _USE_MATH_DEFINES) # for M_PI macro
    endif ()
    if (MSVC)
        list(APPEND _XGD_COMPILE_OPTIONS
                /MP             # multi processor build
                /utf-8          # correct msvc charset
                /bigobj         # big obj
                # get correct __cplusplus macro
                /Zc:__cplusplus)
        list(APPEND _XGD_LINK_OPTIONS /manifest:no) # do not generate manifest
        # crt
        # set_target_properties(${TARGET} PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    endif ()
    if (EMSCRIPTEN)
        list(APPEND _XGD_COMPILE_OPTIONS
                -frtti
                -fexceptions
                -sUSE_PTHREADS=1)
        list(APPEND _XGD_LINK_OPTIONS
                -fexceptions
                -frtti
                -sALLOW_BLOCKING_ON_MAIN_THREAD=1
                -sASSERTIONS=1
                -sASYNCIFY
                -sPTHREAD_POOL_SIZE_STRICT=0
                -sSAFE_HEAP=1
                # -sSINGLE_FILE=1
                -sTOTAL_MEMORY=1024MB
                -sTOTAL_STACK=4MB
                -sUSE_PTHREADS=1)
        if (XGD_WASM_ENV)
            list(APPEND _XGD_LINK_OPTIONS
                    # -sPROXY_TO_PTHREAD
                    # -sEXIT_RUNTIME=1
                    # -sPTHREAD_POOL_SIZE=16
                    -sENVIRONMENT=${XGD_WASM_ENV})
        endif ()
    endif ()

    if (XGD_ENABLE_FLAG_MARCH_NATIVE)
        list(APPEND _XGD_COMPILE_OPTIONS -march=native)
    endif ()
    if (XGD_ENABLE_EMSCRIPTEN_SIMD)
        list(APPEND _XGD_COMPILE_OPTIONS -msimd128)
    elseif (XGD_ENABLE_ARCH_X86)
        if (MSVC)
            if (XGD_ENABLE_FLAG_AVX)
                list(APPEND _XGD_COMPILE_OPTIONS /arch:AVX)
            endif ()
            if (XGD_ENABLE_FLAG_AVX2)
                list(APPEND _XGD_COMPILE_OPTIONS /arch:AVX2)
            endif ()
        else ()
            if (XGD_ENABLE_FLAG_SSE)
                list(APPEND _XGD_COMPILE_OPTIONS
                        -mf16c -mfma
                        -msse3 -msse4.1 -msse4.2 -mssse3
                        -msse -msse2)
            endif ()
            if (XGD_ENABLE_FLAG_AVX)
                list(APPEND _XGD_COMPILE_OPTIONS -mavx)
            endif ()
            if (XGD_ENABLE_FLAG_AVX2)
                list(APPEND _XGD_COMPILE_OPTIONS -mavx2)
            endif ()
        endif ()
    endif ()

    if (EMSCRIPTEN)
        list(APPEND _XGD_COMPILE_DEFINITIONS __SSE__ __SSE2__ __AVX__)
    else ()
        if (XGD_ENABLE_FLAG_SSE)
            list(APPEND _XGD_COMPILE_DEFINITIONS __SSE__ __SSE2__)
            list(APPEND _XGD_COMPILE_DEFINITIONS __SSE3__ __SSSE3__ __SSE4_1__ __SSE4_2__ __FMA__ __F16C__)
        endif ()
        if (XGD_ENABLE_FLAG_AVX)
            list(APPEND _XGD_COMPILE_DEFINITIONS __AVX__)
        endif ()
        if (XGD_ENABLE_FLAG_AVX2)
            list(APPEND _XGD_COMPILE_DEFINITIONS __AVX2__)
        endif ()
    endif ()

    if (COMPILE_DEFINITIONS)
        target_compile_definitions(${TARGET} PRIVATE $<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:${COMPILE_DEFINITIONS}>)
    endif ()
    if (COMPILE_OPTIONS)
        target_compile_options(${TARGET} PRIVATE $<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:${COMPILE_OPTIONS}>)
    endif ()
    if (LINK_OPTIONS)
        target_link_options(${TARGET} PRIVATE ${LINK_OPTIONS})
    endif ()
    set(_XGD_CXX_STANDARD 20)
    if (param_CXX_STANDARD)
        set(_XGD_CXX_STANDARD ${param_CXX_STANDARD})
    endif ()
    set_target_properties(
            ${TARGET} PROPERTIES
            C_STANDARD 11       # C11
            C_STANDARD_REQUIRED ON
            CXX_STANDARD ${_XGD_CXX_STANDARD}
            CXX_STANDARD_REQUIRED ON
            CUDA_STANDARD 17    # CUDA C++17
            CUDA_STANDARD_REQUIRED ON
            # Export only public symbols
            CXX_VISIBILITY_PRESET hidden
            VISIBILITY_INLINES_HIDDEN ON
            POSITION_INDEPENDENT_CODE ON
            CMAKE_DEBUG_POSTFIX "${XGD_POSTFIX}"
    )
    if (NOT MINGW) # mxe heavily dependent on it
        set_target_properties(${TARGET} PROPERTIES CXX_EXTENSIONS OFF)
    endif ()
endfunction()

function(xgd_print_global_options)
    message(STATUS "Summary:
    XGD_USE_OPENMP:\t${XGD_USE_OPENMP}
    XGD_USE_CUDA:\t${XGD_USE_CUDA}
    XGD_USE_QT:\t${XGD_USE_QT}
    XGD_USE_VK:\t${XGD_USE_VK}
    XGD_USE_TORCH:\t${XGD_USE_TORCH}
    XGD_USE_OPENCV:\t${XGD_USE_OPENCV}
    XGD_USE_CCACHE:\t${XGD_USE_CCACHE}
    
    XGD_ENABLE_ARCH_X86:\t${XGD_ENABLE_ARCH_X86}
    XGD_ENABLE_ARCH_ARM:\t${XGD_ENABLE_ARCH_ARM}
    XGD_ENABLE_ARCH_MIPS:\t${XGD_ENABLE_ARCH_MIPS}
    XGD_ENABLE_ARCH_POWER:\t${XGD_ENABLE_ARCH_POWER}
    XGD_ENABLE_ARCH_32:\t${XGD_ENABLE_ARCH_32}
    XGD_ENABLE_ARCH_64:\t${XGD_ENABLE_ARCH_64}
    XGD_ENABLE_FLAG_NEON:\t${XGD_ENABLE_FLAG_NEON}
    XGD_ENABLE_FLAG_SSE:\t${XGD_ENABLE_FLAG_SSE}
    XGD_ENABLE_FLAG_AVX:\t${XGD_ENABLE_FLAG_AVX}
    XGD_ENABLE_FLAG_AVX2:\t${XGD_ENABLE_FLAG_AVX2}
    XGD_ENABLE_FLAG_MARCH_NATIVE:\t${XGD_ENABLE_FLAG_MARCH_NATIVE}
    XGD_ENABLE_EMSCRIPTEN_SIMD:\t${XGD_ENABLE_EMSCRIPTEN_SIMD}
    
    XGD_BUILD_WITH_GRADLE:\t${XGD_BUILD_WITH_GRADLE}
    XGD_NO_DEBUG_CONSOLE:\t${XGD_NO_DEBUG_CONSOLE}

    XGD_WINE64_RUNTIME:\t${XGD_WINE64_RUNTIME}
    XGD_NODEJS_RUNTIME:\t${XGD_NODEJS_RUNTIME}
    XGD_POSTFIX:\t${XGD_POSTFIX}
    XGD_WASM_ENV:\t${XGD_WASM_ENV}
    XGD_QT_MODULES:\t${XGD_QT_MODULES}
    ")
endfunction()

function(xgd_check_global_options)
    include(CheckCXXCompilerFlag)
    include(CheckIncludeFile)
    include(CheckIncludeFiles)
    include(CheckSymbolExists)
    include(CheckFunctionExists)

    set(_XGD_BOOST_DIR ${XGD_EXTERNAL_DIR}/cpp/boost-src/boost/libs)
    set(_XGD_BOOST_CHECK_DIR ${_XGD_BOOST_DIR}/config/checks/architecture)
    check_cxx_source_compiles("
            #include <${_XGD_BOOST_CHECK_DIR}/64.cpp>
            int main() {}" _XGD_BOOST_ARCH_64)
    if (NOT _XGD_BOOST_ARCH_64)
        check_cxx_source_compiles("
            #include <${_XGD_BOOST_CHECK_DIR}/32.cpp>
            int main() {}" _XGD_BOOST_ARCH_32)
    endif ()

    while (1)
        if (EMSCRIPTEN)
            break()
        endif ()
        check_cxx_source_compiles("
                #include <${_XGD_BOOST_CHECK_DIR}/x86.cpp>
                int main() {}" _XGD_BOOST_ARCH_X86)
        if (_XGD_BOOST_ARCH_X86)
            break()
        endif ()
        check_cxx_source_compiles("
                #include <${_XGD_BOOST_CHECK_DIR}/arm.cpp>
                int main() {}" _XGD_BOOST_ARCH_ARM)
        if (_XGD_BOOST_ARCH_ARM)
            break()
        endif ()
        check_cxx_source_compiles("
                #include <${CHECK_SRC_DIR}/mips.cpp>
                int main() {}" _XGD_BOOST_ARCH_MIPS)
        if (_XGD_BOOST_ARCH_MIPS)
            break()
        endif ()
        check_cxx_source_compiles("
                #include <${CHECK_SRC_DIR}/power.cpp>
                int main() {}" _XGD_BOOST_ARCH_POWER)
    endwhile ()

    if (XGD_ENABLE_ARCH_32 AND NOT _XGD_BOOST_ARCH_32)
        set(XGD_ENABLE_ARCH_32 OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_ENABLE_ARCH_64 AND NOT _XGD_BOOST_ARCH_64)
        set(XGD_ENABLE_ARCH_64 OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_ENABLE_ARCH_X86 AND NOT _XGD_BOOST_ARCH_X86)
        set(XGD_ENABLE_ARCH_X86 OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_ENABLE_ARCH_ARM AND NOT _XGD_BOOST_ARCH_ARM)
        set(XGD_ENABLE_ARCH_ARM OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_ENABLE_ARCH_MIPS AND NOT _XGD_BOOST_ARCH_MIPS)
        set(XGD_ENABLE_ARCH_MIPS OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_ENABLE_ARCH_POWER AND NOT _XGD_BOOST_ARCH_POWER)
        set(XGD_ENABLE_ARCH_POWER OFF CACHE INTERNAL "" FORCE)
    endif ()

    if (XGD_ENABLE_FLAG_NEON AND NOT (XGD_ENABLE_ARCH_64 AND XGD_ENABLE_ARCH_ARM))
        set(XGD_ENABLE_FLAG_NEON OFF CACHE INTERNAL "" FORCE)
    endif ()

    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        check_cxx_compiler_flag("-march=native" _XGD_MARCH_NATIVE)
    endif ()
    if (XGD_ENABLE_FLAG_MARCH_NATIVE AND NOT _XGD_MARCH_NATIVE)
        set(XGD_ENABLE_FLAG_MARCH_NATIVE OFF CACHE INTERNAL "" FORCE)
    endif ()

    if (EMSCRIPTEN)
        check_cxx_compiler_flag("-msimd128" _XGD_WASM_SIMD128)
    endif ()
    if (XGD_ENABLE_EMSCRIPTEN_SIMD AND NOT _XGD_WASM_SIMD128)
        set(XGD_ENABLE_EMSCRIPTEN_SIMD OFF CACHE INTERNAL "" FORCE)
    endif ()

    if (XGD_ENABLE_ARCH_X86 AND NOT EMSCRIPTEN)
        if (MSVC)
            # /arch:SSE and /arch:SSE2 doesn't work and is enabled by default
            set(_XGD_SSE ON)
            check_cxx_compiler_flag("/arch:AVX" _XGD_AVX)
            check_cxx_compiler_flag("/arch:AVX2" _XGD_AVX2)
        else ()
            check_cxx_compiler_flag("-msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mfma -mf16c" _XGD_SSE)
            check_cxx_compiler_flag("-mavx" _XGD_AVX)
            check_cxx_compiler_flag("-mavx2" _XGD_AVX2)
        endif ()
    endif ()
    if (XGD_ENABLE_FLAG_SSE AND NOT _XGD_SSE)
        set(XGD_ENABLE_FLAG_SSE OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_ENABLE_FLAG_AVX AND NOT _XGD_AVX)
        set(XGD_ENABLE_FLAG_AVX OFF CACHE INTERNAL "" FORCE)
    endif ()
    if (XGD_ENABLE_FLAG_AVX2 AND NOT _XGD_AVX2)
        set(XGD_ENABLE_FLAG_AVX2 OFF CACHE INTERNAL "" FORCE)
    endif ()

    # include(ProcessorCount)
    # ProcessorCount(_XGD_PROCESSOR_COUNT)

    # boost check
    if (XGD_ENABLE_ARCH_X86 AND NOT EMSCRIPTEN)
        check_cxx_source_compiles(
                "#include <${_XGD_BOOST_DIR}/atomic/config/has_sse2.cpp>"
                XGD_CPP_HAS_SSE2
        )
        check_cxx_source_compiles(
                "#include <${_XGD_BOOST_DIR}/atomic/config/has_sse41.cpp>"
                XGD_CPP_HAS_SSE41
        )
    endif ()
    check_cxx_source_compiles(
            "#include <${_XGD_BOOST_DIR}/filesystem/config/has_cxx20_atomic_ref.cpp>"
            XGD_CPP_HAS_CXX20_ATOMIC_REF
    )
    if (NOT MSVC)
        # openbabel
        check_include_file(sys/time.h XGD_HAVE_SYS_TIME_H)
        check_include_file(rpc/xdr.h XGD_HAVE_RPC_XDR_H)
        check_symbol_exists(rint "math.h" XGD_HAVE_RINT)
        check_symbol_exists(snprintf "stdio.h" XGD_HAVE_SNPRINTF)
        check_symbol_exists(sranddev "stdlib.h" XGD_HAVE_SRANDDEV)
        check_symbol_exists(strcasecmp "string.h" XGD_HAVE_STRCASECMP)
        check_symbol_exists(strncasecmp "string.h" XGD_HAVE_STRNCASECMP)

        # xml
        check_include_files(unistd.h XGD_HAVE_UNISTD_H)
        check_include_files(stdint.h XGD_HAVE_STDINT_H)
        check_include_files(pthread.h XGD_HAVE_PTHREAD_H)
        check_include_files(fcntl.h XGD_HAVE_FCNTL_H)
        check_include_files(sys/stat.h XGD_HAVE_SYS_STAT_H)
        check_function_exists(stat XGD_HAVE_STAT)
    endif ()
endfunction()

function(xgd_mark_generated TARGETS)
    set_source_files_properties(${TARGETS} PROPERTIES GENERATED TRUE)
endfunction()

# common library
function(xgd_add_library TARGET)
    # usage
    # xgd_add_library(your-awesome-target SRC_DIRS [...] SRC_FILES [...] INCLUDE_DIRS [...] PRIVATE_INCLUDE_DIRS [...])
    cmake_parse_arguments(
            param
            "STATIC;SHARED"
            ""
            "SRC_DIRS;SRC_FILES;INCLUDE_DIRS;PRIVATE_INCLUDE_DIRS;EXCLUDE_SRC_FILES;EXCLUDE_REGEXES"
            ${ARGN}
    )
    foreach (SRC_DIR ${param_SRC_DIRS})
        aux_source_directory(${SRC_DIR} ${TARGET}_SOURCES)
    endforeach ()
    foreach (EXCLUDE_REGEX ${param_EXCLUDE_REGEXES})
        list(FILTER ${TARGET}_SOURCES EXCLUDE REGEX "${EXCLUDE_REGEX}")
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
    xgd_target_global_options(${TARGET})
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
    set(RC_FILE ${XGD_ASSET_DIR}/xgd_lib.rc)
    if (NOT (XGD_PRODUCTION_BUILD AND EXISTS ${RC_FILE}))
        return()
    endif ()
    if (WIN32)
        target_sources(${TARGET} PRIVATE ${RC_FILE})
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
