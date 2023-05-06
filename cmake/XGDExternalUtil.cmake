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
        if (XGD_FLAG_WASM_SIMD128)
            list(APPEND _XGD_COMPILE_OPTIONS -msimd128)
            list(APPEND _XGD_COMPILE_DEFINITIONS __SSE__ __SSE2__ __SSE3__ __SSSE3__ __SSE4_1__ __SSE4_2__)
        endif ()
    else ()
        if (XGD_FLAG_MARCH_NATIVE)
            list(APPEND _XGD_COMPILE_OPTIONS -march=native)
        endif ()
        if (XGD_OPT_ARCH_X86)
            if (XGD_FLAG_SSE_ALL)
                list(APPEND _XGD_COMPILE_DEFINITIONS __SSE__ __SSE2__ __SSE3__ __SSSE3__ __SSE4_1__ __SSE4_2__)
            endif ()
            if (XGD_FLAG_AVX)
                list(APPEND _XGD_COMPILE_DEFINITIONS __AVX__)
            endif ()
            if (XGD_FLAG_AVX2)
                list(APPEND _XGD_COMPILE_DEFINITIONS __AVX2__)
            endif ()
            if (XGD_FLAG_FMA)
                list(APPEND _XGD_COMPILE_DEFINITIONS __FMA__)
            endif ()
            if (XGD_FLAG_F16C)
                list(APPEND _XGD_COMPILE_DEFINITIONS __F16C__)
            endif ()

            if (MSVC)
                if (XGD_FLAG_AVX)
                    list(APPEND _XGD_COMPILE_OPTIONS /arch:AVX)
                endif ()
                if (XGD_FLAG_AVX2)
                    list(APPEND _XGD_COMPILE_OPTIONS /arch:AVX2)
                endif ()
            else ()
                if (XGD_FLAG_SSE_ALL)
                    list(APPEND _XGD_COMPILE_OPTIONS -msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2)
                endif ()
                if (XGD_FLAG_AVX)
                    list(APPEND _XGD_COMPILE_OPTIONS -mavx)
                endif ()
                if (XGD_FLAG_AVX2)
                    list(APPEND _XGD_COMPILE_OPTIONS -mavx2)
                endif ()
                if (XGD_FLAG_FMA)
                    list(APPEND _XGD_COMPILE_OPTIONS -mfma)
                endif ()
                if (XGD_FLAG_F16C)
                    list(APPEND _XGD_COMPILE_OPTIONS -mf16c)
                endif ()
            endif ()
        endif ()
    endif ()

    if (_XGD_COMPILE_DEFINITIONS)
        target_compile_definitions(${TARGET} PRIVATE $<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:${_XGD_COMPILE_DEFINITIONS}>)
    endif ()
    if (_XGD_COMPILE_OPTIONS)
        target_compile_options(${TARGET} PRIVATE $<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:${_XGD_COMPILE_OPTIONS}>)
    endif ()
    if (_XGD_LINK_OPTIONS)
        target_link_options(${TARGET} PRIVATE ${_XGD_LINK_OPTIONS})
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
    if (NOT (MINGW AND (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"))) # mxe heavily dependent on extensions
        set_target_properties(${TARGET} PROPERTIES CXX_EXTENSIONS OFF)
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

# common executable
function(xgd_add_executable TARGET)
    cmake_parse_arguments(
            param
            "BUNDLE_QT_GUI"
            ""
            "SRC_DIRS;SRC_FILES;INCLUDE_DIRS;EXCLUDE_SRC_FILES;EXCLUDE_REGEXES"
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

    if (ANDROID)
        ## if use qt_add_executable in CI, use the following codes to skip apk build in "all" target
        # set(ANDROID_PACKAGE_SOURCE_DIR ${XGD_ASSET_DIR}/android/${TARGET})
        # if (EXISTS ${ANDROID_PACKAGE_SOURCE_DIR}/AndroidManifest.xml)
        #     set_target_properties(${TARGET} PROPERTIES QT_ANDROID_PACKAGE_SOURCE_DIR ${ANDROID_PACKAGE_SOURCE_DIR})
        # endif ()
        if (param_BUNDLE_QT_GUI)
            qt_add_executable(${TARGET} MANUAL_FINALIZATION ${${TARGET}_SOURCES})
            qt_finalize_target(${TARGET})
            xgd_exclude_from_all(${TARGET}_prepare_apk_dir)
            xgd_exclude_from_all(apk_all)
        else ()
            # do not run qt_add_executable here, we use customized android shell project
            add_executable(${TARGET} ${${TARGET}_SOURCES})
        endif ()
    elseif (EMSCRIPTEN) # web environment
        if (XGD_WASM_NODE)
            add_executable(${TARGET} ${${TARGET}_SOURCES})
        elseif (param_BUNDLE_QT_GUI)
            qt_add_executable(${TARGET} ${${TARGET}_SOURCES})
            set_target_properties(
                    ${TARGET} PROPERTIES
                    RUNTIME_OUTPUT_DIRECTORY ${XGD_FRONTEND_DIR}/homepage/dist-qt/${TARGET}
                    # QT_WASM_PTHREAD_POOL_SIZE navigator.hardwareConcurrency
                    QT_WASM_PTHREAD_POOL_SIZE 4
            )
            target_link_options(${TARGET} PRIVATE -sPTHREAD_POOL_SIZE_STRICT=0)
        else ()
            # Qt${QT_VERSION_MAJOR}::Platform have "-sMODULARIZE=1;-sEXPORT_NAME=createQtAppInstance" linker flags
            # TO run output js file in CI, intentionally call exposed function at the end
            # e.g. node -e 'import("./hello-opencv.js").then(m=>m?.default?.())'
            add_executable(${TARGET} ${${TARGET}_SOURCES})
            target_link_options(${TARGET} PRIVATE -sPTHREAD_POOL_SIZE=4)
        endif ()
    else ()
        if (param_BUNDLE_QT_GUI)
            qt_add_executable(${TARGET} ${${TARGET}_SOURCES})
            xgd_program_apply_release_info(${TARGET})
        else ()
            add_executable(${TARGET} ${${TARGET}_SOURCES})
        endif ()
    endif ()
    target_include_directories(${TARGET} PRIVATE ${param_INCLUDE_DIRS})
    xgd_target_global_options(${TARGET})
    set_target_properties(${TARGET} PROPERTIES BUNDLE_QT_GUI "${param_BUNDLE_QT_GUI}")
    if (ANDROID AND param_BUNDLE_QT_GUI)
        # expose main function
        set_target_properties(${TARGET} PROPERTIES CXX_VISIBILITY_PRESET default)
    endif ()
endfunction()
