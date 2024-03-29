function(xgd_add_binary_target BINARY_FILE CPP_FILE CPP_VARIABLE_NAME NAMESPACE)
    if (EXISTS "${CPP_FILE}")
        if ("${CPP_FILE}" IS_NEWER_THAN "${BINARY_FILE}")
            return()
        endif ()
    endif ()
    if (NOT EXISTS "${BINARY_FILE}")
        message(FATAL "${BINARY_FILE} doesn't exist")
        return()
    endif ()
    file(READ "${BINARY_FILE}" HEX_CONTENT HEX)

    string(REPEAT "[0-9a-f]" 32 pattern)
    string(REGEX REPLACE "(${pattern})" "\\1\n" BINARY_CONTENT "${HEX_CONTENT}")
    string(REGEX REPLACE "([0-9a-f][0-9a-f])" "0x\\1," BINARY_CONTENT "${BINARY_CONTENT}")
    string(REGEX REPLACE ", $" "" BINARY_CONTENT "${BINARY_CONTENT}")

    set(CPP_SOURCE_ARRAY_DEF "const std::vector<unsigned char> ${CPP_VARIABLE_NAME} = {\n${BINARY_CONTENT}\n};")

    get_filename_component(CPP_FILE_NAME ${CPP_FILE} NAME)

    set(CPP_SOURCE "/**\n * @file ${CPP_FILE_NAME}\n * @brief Auto generated file.\n */\n#include <vector>\nnamespace xgd::${NAMESPACE} {\n${CPP_SOURCE_ARRAY_DEF}\n}")

    file(WRITE "${CPP_FILE}" "${CPP_SOURCE}")
endfunction()
if (EXISTS "${BINARY_FILE}")
    xgd_add_binary_target("${BINARY_FILE}" "${CPP_FILE}" "${CPP_VARIABLE_NAME}" "${NAMESPACE}")
else ()
    message(WARNING "\"${BINARY_FILE}\" not exist")
endif ()