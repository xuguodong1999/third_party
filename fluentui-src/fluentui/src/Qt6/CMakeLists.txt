project(fluentui)

# fluentui
set(ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(INC_DIR ${ROOT_DIR}/../)
set(SRC_DIR ${ROOT_DIR}/../)

file(GLOB_RECURSE QML_PATHS ${ROOT_DIR}/*.qml)
foreach (filepath ${QML_PATHS})
    string(REPLACE "${ROOT_DIR}/" "" filename ${filepath})
    list(APPEND qml_files ${filename})
endforeach (filepath)

file(GLOB_RECURSE RES_PATHS
        ${ROOT_DIR}/*.png ${ROOT_DIR}/*.jpg
        ${ROOT_DIR}/*.svg ${ROOT_DIR}/*.ico
        ${ROOT_DIR}/*.ttf ${ROOT_DIR}/*.webp
        ${ROOT_DIR}/*.js)
foreach (filepath ${RES_PATHS})
    string(REPLACE "${ROOT_DIR}/" "" filename ${filepath})
    list(APPEND resource_files ${filename})
endforeach (filepath)

foreach (filepath IN LISTS qml_files resource_files)
    string(REPLACE "imports/FluentUI/" "" filename ${filepath})
    set_source_files_properties(${filepath} PROPERTIES QT_RESOURCE_ALIAS ${filename})
endforeach ()

if (CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    set(OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/FluentUI")
else ()
    set(OUTPUT_DIRECTORY FluentUI)
endif ()

#set(CMAKE_AUTOMOC ON)
#set(CMAKE_AUTORCC ON)

xgd_add_library(${PROJECT_NAME} PRIVATE_INCLUDE_DIRS ${INC_DIR})
xgd_link_qt(${PROJECT_NAME} PRIVATE Quick)

aux_source_directory(${SRC_DIR} source_files)
aux_source_directory(${SRC_DIR}/qrcode source_files)
list(REMOVE_ITEM source_files "${SRC_DIR}/fluentuiplugin.cpp")

# create target ${PROJECT_NAME}plugin
qt_add_qml_module(${PROJECT_NAME}
        PLUGIN_TARGET ""
        OUTPUT_DIRECTORY "${OUTPUT_DIRECTORY}"
        VERSION 1.0
        URI FluentUI
        TYPEINFO "plugins.qmltypes"
        SOURCES ${source_files}
        QML_FILES ${qml_files}
        RESOURCES ${resource_files}
        RESOURCE_PREFIX "/")

target_compile_definitions(fluentui PRIVATE HAVE_CONFIG_H)
if (NOT BUILD_SHARED_LIBS)
    target_compile_definitions(fluentui PRIVATE FLUENTUI_BUILD_STATIC_LIB)
endif ()
