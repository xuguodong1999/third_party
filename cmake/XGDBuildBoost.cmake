# boost
function(xgd_internal_build_boost BOOST_COMPONENT)
    set(BOOST_INC_DIR ${XGD_EXTERNAL_DIR}/cpp/boost-src/boost)
    set(BOOST_SRC_DIR ${XGD_EXTERNAL_DIR}/cpp/boost-src/boost/libs)
    cmake_parse_arguments(param "STATIC" "" "SRC_FILES;SRC_DIRS" ${ARGN})
    set(${BOOST_COMPONENT}_SRC_DIR ${BOOST_SRC_DIR}/${BOOST_COMPONENT}/src)
    if (NOT param_SRC_FILES)
        set(${BOOST_COMPONENT}_SRC_DIRS ${${BOOST_COMPONENT}_SRC_DIR})
        foreach (SRC_DIR ${param_SRC_DIRS})
            list(APPEND ${BOOST_COMPONENT}_SRC_DIRS ${${BOOST_COMPONENT}_SRC_DIR}/${SRC_DIR})
        endforeach ()
    endif ()
    set(${BOOST_COMPONENT}_SRC_FILES)
    foreach (SRC_FILE ${param_SRC_FILES})
        list(APPEND ${BOOST_COMPONENT}_SRC_FILES ${${BOOST_COMPONENT}_SRC_DIR}/${SRC_FILE})
    endforeach ()
    if (param_STATIC)
        xgd_add_library(
                boost_${BOOST_COMPONENT}
                STATIC
                SRC_DIRS ${${BOOST_COMPONENT}_SRC_DIRS}
                SRC_FILES ${${BOOST_COMPONENT}_SRC_FILES}
                INCLUDE_DIRS ${BOOST_INC_DIR}
        )
    else ()
        xgd_add_library(
                boost_${BOOST_COMPONENT}
                SRC_DIRS ${${BOOST_COMPONENT}_SRC_DIRS}
                SRC_FILES ${${BOOST_COMPONENT}_SRC_FILES}
                INCLUDE_DIRS ${BOOST_INC_DIR}
        )
    endif ()
    add_library(Boost::${BOOST_COMPONENT} ALIAS boost_${BOOST_COMPONENT})
    target_include_directories(boost_${BOOST_COMPONENT} PRIVATE ${${BOOST_COMPONENT}_SRC_DIR})
    target_compile_definitions(boost_${BOOST_COMPONENT} PUBLIC BOOST_ALL_NO_LIB _HAS_AUTO_PTR_ETC=0)
    if (WIN32 AND BUILD_SHARED_LIBS)
        target_compile_definitions(
                boost_${BOOST_COMPONENT}
                PUBLIC
                BOOST_ALL_DYN_LINK
                BOOST_THREAD_USE_DLL
        )
    else ()
        target_compile_definitions(
                boost_${BOOST_COMPONENT}
                PRIVATE
                BOOST_ALL_DYN_LINK
                BOOST_THREAD_USE_LIB
        )
    endif ()
    if (NOT TARGET boost_all)
        add_custom_target(boost_all)
    endif ()
    add_dependencies(boost_all boost_${BOOST_COMPONENT})
endfunction()

function(xgd_build_boost_atomic)
    set(BOOST_SRC_DIR ${XGD_EXTERNAL_DIR}/cpp/boost-src/boost/libs)
    set(BOOST_ATOMIC_SRC_FILES lock_pool.cpp)
    if (WIN32)
        list(APPEND BOOST_ATOMIC_SRC_FILES wait_on_address.cpp)
    endif ()
    if (XGD_ARCH_X86)
        check_cxx_source_compiles(
                "#include <${BOOST_SRC_DIR}/atomic/config/has_sse2.cpp>"
                BOOST_ATOMIC_COMPILER_HAS_SSE2
        )
        if (BOOST_ATOMIC_COMPILER_HAS_SSE2)
            list(APPEND BOOST_ATOMIC_SRC_FILES find_address_sse2.cpp)
        endif ()
        check_cxx_source_compiles(
                "#include <${BOOST_SRC_DIR}/atomic/config/has_sse41.cpp>"
                BOOST_ATOMIC_COMPILER_HAS_SSE41
        )
        if (BOOST_ATOMIC_COMPILER_HAS_SSE41)
            list(APPEND BOOST_ATOMIC_SRC_FILES find_address_sse41.cpp)
        endif ()
    endif ()
    xgd_internal_build_boost(atomic SRC_FILES ${BOOST_ATOMIC_SRC_FILES})
    target_compile_definitions(boost_atomic PRIVATE BOOST_ATOMIC_SOURCE)
endfunction()

function(xgd_build_boost_filesystem)
    set(BOOST_SRC_DIR ${XGD_EXTERNAL_DIR}/cpp/boost-src/boost/libs)
    check_cxx_source_compiles(
            "#include <${BOOST_SRC_DIR}/filesystem/config/has_cxx20_atomic_ref.cpp>"
            BOOST_FILESYSTEM_HAS_CXX20_ATOMIC_REF
    )

    set(BOOST_FILESYSTEM_SOURCES
            codecvt_error_category.cpp
            exception.cpp
            operations.cpp
            directory.cpp
            path.cpp
            path_traits.cpp
            portability.cpp
            unique_path.cpp
            utf8_codecvt_facet.cpp)
    if (WIN32 OR CYGWIN)
        list(APPEND BOOST_FILESYSTEM_SOURCES windows_file_codecvt.cpp)
    endif ()
    xgd_internal_build_boost(
            filesystem SRC_FILES ${BOOST_FILESYSTEM_SOURCES}
    )
    target_compile_definitions(boost_filesystem PRIVATE BOOST_FILESYSTEM_SOURCE)
    if (WIN32)
        target_compile_definitions(boost_filesystem PRIVATE
                _SCL_SECURE_NO_WARNINGS _SCL_SECURE_NO_DEPRECATE _CRT_SECURE_NO_WARNINGS _CRT_SECURE_NO_DEPRECATE)
    endif ()
    if (WIN32 OR CYGWIN)
        target_compile_definitions(boost_filesystem PRIVATE BOOST_USE_WINDOWS_H WIN32_LEAN_AND_MEAN NOMINMAX)
    endif ()

    target_compile_definitions(boost_filesystem PUBLIC BOOST_FILESYSTEM_NO_DEPRECATED)
    if (NOT BOOST_FILESYSTEM_HAS_CXX20_ATOMIC_REF)
        target_compile_definitions(boost_filesystem PRIVATE BOOST_FILESYSTEM_NO_CXX20_ATOMIC_REF)
        xgd_link_boost(boost_filesystem PRIVATE atomic)
    endif ()

    if (WIN32)
        target_compile_definitions(boost_filesystem PRIVATE BOOST_FILESYSTEM_HAS_WINCRYPT)
        if (NOT WINCE)
            target_link_libraries(boost_filesystem PRIVATE advapi32)
        else ()
            target_link_libraries(boost_filesystem PRIVATE coredll)
        endif ()
    endif ()
endfunction()

function(xgd_build_boost_thread)
    if (WIN32 OR CYGWIN)
        set(BOOST_THREAD_BACKENDS win32/thread.cpp win32/thread_primitives.cpp win32/tss_dll.cpp win32/tss_pe.cpp)
    else ()
        set(BOOST_THREAD_BACKENDS pthread/once.cpp pthread/thread.cpp)
    endif ()
    xgd_internal_build_boost(thread SRC_FILES ${BOOST_THREAD_BACKENDS})
    target_compile_definitions(boost_thread PRIVATE BOOST_THREAD_SOURCE)
    if (BUILD_SHARED_LIBS)
        target_compile_definitions(boost_thread PUBLIC BOOST_THREAD_BUILD_DLL)
    else ()
        target_compile_definitions(boost_thread PUBLIC BOOST_THREAD_BUILD_DLL BOOST_THREAD_BUILD_LIB)
    endif ()
    xgd_link_threads(boost_thread PUBLIC)
endfunction()

function(xgd_build_boost_stacktrace)
    if (WIN32)
        set(BOOST_STACKTRACE_SRC windbg.cpp)
        set(BOOST_STACKTRACE_LIB ole32 dbgeng)
    elseif (EMSCRIPTEN)
        set(BOOST_STACKTRACE_SRC noop.cpp)
    else ()
        set(BOOST_STACKTRACE_SRC basic.cpp)
        set(BOOST_STACKTRACE_LIB dl)
    endif ()
    xgd_internal_build_boost(stacktrace SRC_FILES ${BOOST_STACKTRACE_SRC})
    if (EMSCRIPTEN)
        target_compile_definitions(boost_stacktrace PUBLIC BOOST_STACKTRACE_USE_NOOP)
    elseif (UNIX)
        target_compile_definitions(boost_stacktrace PUBLIC "_GNU_SOURCE=1")
    endif ()
    if (BOOST_STACKTRACE_LIB)
        target_link_libraries(boost_stacktrace PUBLIC ${BOOST_STACKTRACE_LIB})
    endif ()
    xgd_link_threads(boost_stacktrace PUBLIC)
endfunction()

function(xgd_build_boost_library)
    xgd_build_boost_atomic()
    xgd_internal_build_boost(chrono)

    xgd_internal_build_boost(
            container
            SRC_FILES
            alloc_lib.c
            dlmalloc.cpp
            global_resource.cpp
            monotonic_buffer_resource.cpp
            pool_resource.cpp
            synchronized_pool_resource.cpp
            unsynchronized_pool_resource.cpp
    )

    xgd_internal_build_boost(contract)

    xgd_internal_build_boost(
            date_time
            SRC_FILES gregorian/greg_month.cpp
    )

    xgd_internal_build_boost(exception STATIC)

    xgd_build_boost_filesystem()

    xgd_internal_build_boost(graph)

    xgd_internal_build_boost(
            iostreams
            SRC_FILES file_descriptor.cpp gzip.cpp mapped_file.cpp zlib.cpp
    )
    xgd_link_zlib(boost_iostreams)

    xgd_internal_build_boost(json)

    # treat boost_math as header-only
    # xgd_internal_build_boost(math SRC_DIRS tr1)

    xgd_internal_build_boost(nowide)

    xgd_internal_build_boost(program_options)

    xgd_internal_build_boost(random)

    xgd_internal_build_boost(regex)

    xgd_internal_build_boost(serialization)

    xgd_internal_build_boost(system)

    xgd_build_boost_thread()

    xgd_internal_build_boost(timer)
    xgd_link_boost(boost_timer PUBLIC chrono)

    xgd_internal_build_boost(type_erasure)
    xgd_link_boost(boost_type_erasure PUBLIC thread)

    xgd_build_boost_stacktrace()

    xgd_internal_build_boost(url)

    xgd_internal_build_boost(
            wave
            SRC_DIRS cpplexer/re2clex
    )
    xgd_link_boost(boost_wave PUBLIC thread filesystem)

    # boost libs not work with my cmake build script yet

    # xgd_internal_build_boost(context)
    # xgd_internal_build_boost(coroutine)
    # xgd_internal_build_boost(fiber)
    # xgd_internal_build_boost(graph_parallel)
    # xgd_internal_build_boost(locale)
    # xgd_internal_build_boost(log)
    # xgd_internal_build_boost(mpi)
    # xgd_internal_build_boost(python)
    # xgd_internal_build_boost(test)
endfunction()