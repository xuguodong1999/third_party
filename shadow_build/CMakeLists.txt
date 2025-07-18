function(xgd_build_third_party)
    set(XGD_THIRD_PARTY_LIBS
            abseil ade agg avalontoolkit
            arrow
            benchmark better-enums boost
            cairo coordgen cppcoro cpufeatures cutlass
            eigen
            flatbuffers
            # fluentui
            # fontconfig
            freesasa freetype
            ggml gtest
            inchi indigo
            # libexpat
            lbfgs libpng libxml2 lunasvg
            maeparser
            nanosvg ncnn
            openbabel opencv openssl
            pixman plutovg protobuf
            quickjs
            rapidjson rdkit ringdecomposerlib rxcpp
            skia
            snappy
            spdlog svgpp
            taskflow tinyxml2
            thrift
            yaehmop yoga
            zlib zstd zxing)
    if (XGD_USE_QT)
        list(APPEND XGD_THIRD_PARTY_LIBS nodeeditor)
    endif ()
    foreach (XGD_THIRD_PARTY_LIB ${XGD_THIRD_PARTY_LIBS})
        include(${CMAKE_SOURCE_DIR}/cmake/build-${XGD_THIRD_PARTY_LIB}.cmake)
    endforeach ()
endfunction()

if (XGD_USE_CUDA)
    enable_language(CUDA)
endif ()

xgd_build_third_party()
