# libxml2
## disable http and module, enable threads
function(xgd_build_xml2_library)
    set(INC_DIR ${XGD_EXTERNAL_DIR}/c/libxml2-src/libxml2/include)
    set(SRC_DIR ${XGD_EXTERNAL_DIR}/c/libxml2-src/libxml2)
    set(_XML_SRC_FILES buf.c c14n.c catalog.c chvalid.c debugXML.c dict.c encoding.c entities.c error.c
            globals.c hash.c HTMLparser.c HTMLtree.c legacy.c list.c nanoftp.c nanohttp.c parser.c
            parserInternals.c pattern.c relaxng.c SAX.c SAX2.c schematron.c threads.c tree.c uri.c
            valid.c xinclude.c xlink.c xmlIO.c xmlmemory.c xmlmodule.c xmlreader.c xmlregexp.c xmlsave.c
            xmlschemas.c xmlschemastypes.c xmlstring.c xmlunicode.c xmlwriter.c xpath.c xpointer.c xzlib.c)
    set(SRC_FILES)
    foreach (XML_SRC ${_XML_SRC_FILES})
        list(APPEND SRC_FILES ${SRC_DIR}/${XML_SRC})
    endforeach ()
    xgd_add_library(
            xml2
            SRC_FILES ${SRC_FILES}
            INCLUDE_DIRS ${INC_DIR}
    )
    xgd_link_zlib(xml2)
    xgd_link_threads(xml2)
    target_compile_definitions(xml2 PRIVATE _REENTRANT)
    if (WIN32)
        target_compile_definitions(xml2 PRIVATE HAVE_WIN32_THREADS)
    endif ()
    if (NOT BUILD_SHARED_LIBS)
        target_compile_definitions(xml2 PUBLIC LIBXML_STATIC)
    endif ()

    set(LIBXML2_WITH_FTP OFF)
    set(LIBXML2_WITH_HTTP OFF)
    set(LIBXML2_WITH_ICONV OFF)
    set(LIBXML2_WITH_ICU OFF)
    set(LIBXML2_WITH_LEGACY OFF)
    set(LIBXML2_WITH_LZMA OFF)
    set(LIBXML2_WITH_MEM_DEBUG OFF)
    set(LIBXML2_WITH_MODULES OFF)
    set(LIBXML2_WITH_RUN_DEBUG OFF)
    set(LIBXML2_WITH_THREAD_ALLOC OFF)
    set(LIBXML2_WITH_TRIO OFF)

    set(LIBXML2_WITH_AUTOMATA ON)
    set(LIBXML2_WITH_C14N ON)
    set(LIBXML2_WITH_CATALOG ON)
    set(LIBXML2_WITH_DEBUG ON)
    set(LIBXML2_WITH_EXPR ON)
    set(LIBXML2_WITH_HTML ON)
    set(LIBXML2_WITH_ISO8859X ON)
    set(LIBXML2_WITH_OUTPUT ON)
    set(LIBXML2_WITH_PATTERN ON)
    set(LIBXML2_WITH_PUSH ON)
    set(LIBXML2_WITH_READER ON)
    set(LIBXML2_WITH_REGEXPS ON)
    set(LIBXML2_WITH_SAX1 ON)
    set(LIBXML2_WITH_SCHEMAS ON)
    set(LIBXML2_WITH_SCHEMATRON ON)
    set(LIBXML2_WITH_THREADS ON)
    set(LIBXML2_WITH_TREE ON)
    set(LIBXML2_WITH_UNICODE ON)
    set(LIBXML2_WITH_VALID ON)
    set(LIBXML2_WITH_WRITER ON)
    set(LIBXML2_WITH_XINCLUDE ON)
    set(LIBXML2_WITH_XPATH ON)
    set(LIBXML2_WITH_XPTR ON)
    set(LIBXML2_WITH_XPTR_LOCS ON)
    set(LIBXML2_WITH_ZLIB ON)

    file(STRINGS "${SRC_DIR}/configure.ac" CONFIGURE_AC_LINES)
    foreach (line ${CONFIGURE_AC_LINES})
        if (line MATCHES [[^m4_define\(\[(MAJOR_VERSION|MINOR_VERSION|MICRO_VERSION)\],[ \t]*([0-9]+)\)$]])
            set(LIBXML_${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
        elseif (line MATCHES "^(LIBXML_MAJOR_VERSION|LIBXML_MINOR_VERSION|LIBXML_MICRO_VERSION)=([0-9]+)$")
            set(${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
        endif ()
    endforeach ()
    set(VERSION "${LIBXML_MAJOR_VERSION}.${LIBXML_MINOR_VERSION}.${LIBXML_MICRO_VERSION}")
    set(LIBXML_VERSION ${VERSION})
    set(LIBXML_VERSION_EXTRA "")
    math(EXPR LIBXML_VERSION_NUMBER
            "${LIBXML_MAJOR_VERSION} * 10000 + ${LIBXML_MINOR_VERSION} * 100 + ${LIBXML_MICRO_VERSION}")
    set(PACKAGE "libxml2")
    set(PACKAGE_BUGREPORT "xml@gnome.org")
    set(PACKAGE_NAME "libxml2")
    set(PACKAGE_STRING "libxml2 ${VERSION}")
    set(PACKAGE_TARNAME "libxml2")
    set(PACKAGE_URL "https://gitlab.gnome.org/GNOME/libxml2")
    set(PACKAGE_VERSION ${VERSION})

    if (NOT MSVC)
        set(HAVE_UNISTD_H ${XGD_HAVE_UNISTD_H})
        set(HAVE_STDINT_H ${XGD_HAVE_STDINT_H})
        set(HAVE_PTHREAD_H ${XGD_HAVE_PTHREAD_H})
        set(HAVE_FCNTL_H ${XGD_HAVE_FCNTL_H})
        set(HAVE_SYS_STAT_H ${XGD_HAVE_SYS_STAT_H})
        set(HAVE_HAVE_STAT ${XGD_HAVE_STAT})
        set(HAVE_VA_COPY 1)
        set(VA_LIST_IS_ARRAY_TEST 0)
        set(VA_LIST_IS_ARRAY 1)
        foreach (VARIABLE IN ITEMS HAVE_ATTRIBUTE_DESTRUCTOR GETHOSTBYNAME_ARG_CAST_CONST HAVE_ARPA_INET_H
                HAVE_ARPA_NAMESER_H HAVE_SS_FAMILY HAVE_BROKEN_SS_FAMILY HAVE_CLASS HAVE_DLFCN_H HAVE_DLOPEN
                HAVE_DL_H HAVE_FPCLASS HAVE_FTIME HAVE_GETADDRINFO HAVE_GETTIMEOFDAY HAVE_INTTYPES_H
                HAVE_ISASCII HAVE_LIBHISTORY HAVE_LIBREADLINE HAVE_MMAP HAVE_MUNMA HAVE_NETDB_H HAVE_NETINET_IN_H
                HAVE_POLL_H HAVE_PUTENV HAVE_RAND_R HAVE_RESOLV_H HAVE_SHLLOAD HAVE___VA_COPY
                HAVE_SYS_MMAN_H HAVE_SYS_SELECT_H HAVE_SYS_SOCKET_H HAVE_SYS_TIMEB_H
                HAVE_SYS_TIME_H HAVE_SYS_TYPES_H XML_SOCKLEN_T_SOCKLEN_T XML_SOCKLEN_T_SOCKLEN_T)
            set(${VARIABLE} 0)
        endforeach ()
    endif ()

    foreach (VARIABLE IN ITEMS WITH_AUTOMATA WITH_C14N WITH_CATALOG WITH_DEBUG WITH_EXPR WITH_FTP
            WITH_HTML WITH_HTTP WITH_ICONV WITH_ICU WITH_ISO8859X WITH_LEGACY WITH_LZMA
            WITH_MEM_DEBUG WITH_MODULES WITH_OUTPUT WITH_PATTERN WITH_PUSH
            WITH_READER WITH_REGEXPS WITH_RUN_DEBUG WITH_SAX1 WITH_SCHEMAS WITH_SCHEMATRON
            WITH_THREAD_ALLOC WITH_THREADS WITH_TREE WITH_TRIO WITH_UNICODE WITH_VALID WITH_WRITER
            WITH_XINCLUDE WITH_XPATH WITH_XPTR WITH_XPTR_LOCS WITH_ZLIB)
        if (LIBXML2_${VARIABLE})
            set(${VARIABLE} 1)
        else ()
            set(${VARIABLE} 0)
        endif ()
    endforeach ()

    set(XML_GEN_DIR ${XGD_GENERATED_DIR}/libxml2/include)
    set(XML_CONF_DIR ${XML_GEN_DIR}/libxml)
    if (MSVC)
        configure_file(${INC_DIR}/win32config.h ${XML_CONF_DIR}/config.h COPYONLY)
    else ()
        configure_file(${SRC_DIR}/config.h.cmake.in ${XML_CONF_DIR}/config.h)
    endif ()
    configure_file(${INC_DIR}/libxml/xmlversion.h.in ${XML_CONF_DIR}/xmlversion.h)
    target_include_directories(xml2 PUBLIC ${XML_GEN_DIR} PRIVATE ${XML_CONF_DIR})
endfunction()