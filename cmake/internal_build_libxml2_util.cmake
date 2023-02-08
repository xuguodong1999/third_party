# libxml2
function(xgd_build_xml2_library)
    set(INC_DIR ${XGD_DEPS_DIR}/cpp/libxml2-src/libxml2/include)
    set(SRC_DIR ${XGD_DEPS_DIR}/cpp/libxml2-src/libxml2)
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
        target_link_libraries(xml2 PRIVATE ws2_32)
        target_compile_definitions(xml2 PRIVATE HAVE_WIN32_THREADS)
    endif ()
    if(NOT BUILD_SHARED_LIBS)
        target_compile_definitions(xml2 PUBLIC LIBXML_STATIC)
    endif()

    set(LIBXML2_WITH_AUTOMATA ON)
    set(LIBXML2_WITH_C14N ON)
    set(LIBXML2_WITH_CATALOG ON)
    set(LIBXML2_WITH_DEBUG ON)
    set(LIBXML2_WITH_EXPR ON)
    set(LIBXML2_WITH_FTP OFF)
    set(LIBXML2_WITH_HTML ON)
    set(LIBXML2_WITH_HTTP ON)
    set(LIBXML2_WITH_ICONV OFF)
    set(LIBXML2_WITH_ICU OFF)
    set(LIBXML2_WITH_ISO8859X ON)
    set(LIBXML2_WITH_LEGACY OFF)
    set(LIBXML2_WITH_LZMA OFF)
    set(LIBXML2_WITH_MEM_DEBUG OFF)
    set(LIBXML2_WITH_MODULES ON)
    set(LIBXML2_WITH_OUTPUT ON)
    set(LIBXML2_WITH_PATTERN ON)
    set(LIBXML2_WITH_PUSH ON)
    set(LIBXML2_WITH_READER ON)
    set(LIBXML2_WITH_REGEXPS ON)
    set(LIBXML2_WITH_RUN_DEBUG OFF)
    set(LIBXML2_WITH_SAX1 ON)
    set(LIBXML2_WITH_SCHEMAS ON)
    set(LIBXML2_WITH_SCHEMATRON ON)

    set(LIBXML2_WITH_THREADS ON)
    set(LIBXML2_WITH_THREAD_ALLOC OFF)
    set(LIBXML2_WITH_TREE ON)
    set(LIBXML2_WITH_TRIO OFF)
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
    math(EXPR LIBXML_VERSION_NUMBER "
    ${LIBXML_MAJOR_VERSION} * 10000 +
    ${LIBXML_MINOR_VERSION} * 100 +
    ${LIBXML_MICRO_VERSION}
    ")

    set(PACKAGE "libxml2")
    set(PACKAGE_BUGREPORT "xml@gnome.org")
    set(PACKAGE_NAME "libxml2")
    set(PACKAGE_STRING "libxml2 ${VERSION}")
    set(PACKAGE_TARNAME "libxml2")
    set(PACKAGE_URL "https://gitlab.gnome.org/GNOME/libxml2")
    set(PACKAGE_VERSION ${VERSION})

    if (NOT MSVC)
        include(CheckCSourceCompiles)
        include(CheckFunctionExists)
        include(CheckIncludeFiles)
        include(CheckLibraryExists)
        include(CheckStructHasMember)
        include(CheckSymbolExists)
        include(CMakePackageConfigHelpers)
        include(GNUInstallDirs)

        check_c_source_compiles("
		void __attribute__((destructor))
		f(void) {}
		int main(void) { return 0; }
	" HAVE_ATTRIBUTE_DESTRUCTOR)
        if (HAVE_ATTRIBUTE_DESTRUCTOR)
            set(ATTRIBUTE_DESTRUCTOR "__attribute__((destructor))")
        endif ()
        check_c_source_compiles("
		#include <netdb.h>
		int main() { (void) gethostbyname((const char*) \"\"); return 0; }
	" GETHOSTBYNAME_ARG_CAST_CONST)
        if (NOT GETHOSTBYNAME_ARG_CAST_CONST)
            set(GETHOSTBYNAME_ARG_CAST "(char *)")
        else ()
            set(GETHOSTBYNAME_ARG_CAST "/**/")
        endif ()
        check_include_files(arpa/inet.h HAVE_ARPA_INET_H)
        check_include_files(arpa/nameser.h HAVE_ARPA_NAMESER_H)
        check_struct_has_member("struct sockaddr_storage" ss_family "sys/socket.h;sys/types.h" HAVE_SS_FAMILY)
        check_struct_has_member("struct sockaddr_storage" __ss_family "sys/socket.h;sys/types.h" HAVE_BROKEN_SS_FAMILY)
        if (HAVE_BROKEN_SS_FAMILY)
            set(ss_family __ss_family)
        endif ()
        check_function_exists(class HAVE_CLASS)
        check_include_files(dlfcn.h HAVE_DLFCN_H)
        check_include_files(pthread.h HAVE_PTHREAD_H)
        check_library_exists(dl dlopen "" HAVE_DLOPEN)
        check_include_files(dl.h HAVE_DL_H)
        check_include_files(fcntl.h HAVE_FCNTL_H)
        check_function_exists(fpclass HAVE_FPCLASS)
        check_function_exists(ftime HAVE_FTIME)
        check_function_exists(getaddrinfo HAVE_GETADDRINFO)
        check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)
        check_include_files(inttypes.h HAVE_INTTYPES_H)
        check_function_exists(isascii HAVE_ISASCII)
        check_library_exists(history append_history "" HAVE_LIBHISTORY)
        check_library_exists(readline readline "" HAVE_LIBREADLINE)
        check_function_exists(mmap HAVE_MMAP)
        check_function_exists(munmap HAVE_MUNMAP)
        check_include_files(netdb.h HAVE_NETDB_H)
        check_include_files(netinet/in.h HAVE_NETINET_IN_H)
        check_include_files(poll.h HAVE_POLL_H)
        check_function_exists(putenv HAVE_PUTENV)
        check_function_exists(rand_r HAVE_RAND_R)
        check_include_files(resolv.h HAVE_RESOLV_H)
        check_library_exists(dld shl_load "" HAVE_SHLLOAD)
        check_function_exists(stat HAVE_STAT)
        check_include_files(stdint.h HAVE_STDINT_H)
        check_include_files(sys/mman.h HAVE_SYS_MMAN_H)
        check_include_files(sys/select.h HAVE_SYS_SELECT_H)
        check_include_files(sys/socket.h HAVE_SYS_SOCKET_H)
        check_include_files(sys/stat.h HAVE_SYS_STAT_H)
        check_include_files(sys/timeb.h HAVE_SYS_TIMEB_H)
        check_include_files(sys/time.h HAVE_SYS_TIME_H)
        check_include_files(sys/types.h HAVE_SYS_TYPES_H)
        check_include_files(unistd.h HAVE_UNISTD_H)
        check_function_exists(va_copy HAVE_VA_COPY)
        check_function_exists(__va_copy HAVE___VA_COPY)
        set(LT_OBJDIR ".libs/")
        check_c_source_compiles("
		#include <sys/socket.h>
		#include <sys/types.h>
		int main() { (void) send(1, (const char*) \"\", 1, 1); return 0; }
	" SEND_ARG2_CAST_CONST)
        if (NOT SEND_ARG2_CAST_CONST)
            set(SEND_ARG2_CAST "(char *)")
        else ()
            set(SEND_ARG2_CAST "/**/")
        endif ()
        check_c_source_compiles("
		#include <stdarg.h>
		void a(va_list* ap) {};
		int main() { va_list ap1, ap2; a(&ap1); ap2 = (va_list) ap1; return 0; }
	" VA_LIST_IS_ARRAY_TEST)
        if (VA_LIST_IS_ARRAY_TEST)
            set(VA_LIST_IS_ARRAY FALSE)
        else ()
            set(VA_LIST_IS_ARRAY TRUE)
        endif ()
        check_c_source_compiles("
		#include <stddef.h>
		#include <sys/socket.h>
		#include <sys/types.h>
		int main() { (void) getsockopt(1, 1, 1, NULL, (socklen_t*) NULL); return 0; }
	" XML_SOCKLEN_T_SOCKLEN_T)
        if (XML_SOCKLEN_T_SOCKLEN_T)
            set(XML_SOCKLEN_T socklen_t)
        else ()
            check_c_source_compiles("
			#include <stddef.h>
			#include <sys/socket.h>
			#include <sys/types.h>
			int main() { (void) getsockopt(1, 1, 1, NULL, (size_t*) NULL); return 0; }
		" XML_SOCKLEN_T_SIZE_T)
            if (XML_SOCKLEN_T_SIZE_T)
                set(XML_SOCKLEN_T size_t)
            else ()
                check_c_source_compiles("
				#include <stddef.h>
				#include <sys/socket.h>
				#include <sys/types.h>
				int main() { (void) getsockopt (1, 1, 1, NULL, (int*) NULL); return 0; }
			" XML_SOCKLEN_T_INT)
                set(XML_SOCKLEN_T int)
            endif ()
        endif ()
    endif ()

    foreach (VARIABLE IN ITEMS WITH_AUTOMATA WITH_C14N WITH_CATALOG WITH_DEBUG WITH_EXPR WITH_FTP
            WITH_HTML WITH_HTTP WITH_ICONV WITH_ICU WITH_ISO8859X WITH_LEGACY WITH_LZMA WITH_MEM_DEBUG
            WITH_MODULES WITH_OUTPUT WITH_PATTERN WITH_PUSH WITH_READER WITH_REGEXPS WITH_RUN_DEBUG
            WITH_SAX1 WITH_SCHEMAS WITH_SCHEMATRON WITH_THREADS WITH_THREAD_ALLOC WITH_TREE WITH_TRIO
            WITH_UNICODE WITH_VALID WITH_WRITER WITH_XINCLUDE WITH_XPATH WITH_XPTR WITH_XPTR_LOCS WITH_ZLIB)
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
