cmake_minimum_required(VERSION 3.22)

project(xgd-third_party VERSION 1.0.1 LANGUAGES C CXX)

set(XGD_THIRD_PARTY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../)

include(cmake/cmake-utils.cmake)
include(cmake/project-config.cmake)

function(xgd_build_third_party)
    set(XGD_THIRD_PARTY_LIBS
            abseil ade avalontoolkit
            benchmark boost
            cairo coordgen cpufeatures cutlass
            eigen
            freesasa freetype
            ggml gtest
            inchi indigo
            lbfgs libpng libxml2
            maeparser
            ncnn nodeeditor
            openbabel opencv openssl
            pixman protobuf
            rapidjson rdkit ringdecomposerlib rxcpp
            spdlog
            taskflow tinyxml2
            yaehmop yoga
            zlib zstd)
    foreach (XGD_THIRD_PARTY_LIB ${XGD_THIRD_PARTY_LIBS})
        include(cmake/build-${XGD_THIRD_PARTY_LIB}.cmake)
    endforeach ()
endfunction()

xgd_build_third_party()

xgd_add_executable(example SRC_FILES example.cpp)
xgd_add_executable(
        asio_ssl_server
        SRC_FILES
        ${XGD_THIRD_PARTY_DIR}/boost-src/boost/libs/asio/example/cpp11/ssl/server.cpp
)
xgd_link_libraries(asio_ssl_server PRIVATE boost_asio)

