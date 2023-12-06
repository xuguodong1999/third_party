function(xgd_build_third_party)
    set(XGD_THIRD_PARTY_LIBS
            abseil ade agg avalontoolkit
            benchmark boost
            cairo coordgen cppcoro cpufeatures cutlass
            eigen
            # fluentui
            freesasa freetype
            ggml gtest
            inchi indigo
            lbfgs libpng libxml2
            maeparser
            nanosvg ncnn nodeeditor
            openbabel opencv openssl
            pixman protobuf
            quickjs
            rapidjson rdkit ringdecomposerlib rxcpp
            skia
            spdlog svgpp
            taskflow tinyxml2
            yaehmop yoga
            zlib zstd zxing)
    foreach (XGD_THIRD_PARTY_LIB ${XGD_THIRD_PARTY_LIBS})
        include(${CMAKE_SOURCE_DIR}/cmake/build-${XGD_THIRD_PARTY_LIB}.cmake)
    endforeach ()
endfunction()

xgd_build_third_party()
