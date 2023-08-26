function(xgd_build_third_party)
    set(XGD_THIRD_PARTY_LIBS
            abseil ade avalontoolkit
            benchmark boost
            cairo coordgen cpufeatures cutlass
            eigen
            # fluentui
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
            zlib zstd zxing)
    foreach (XGD_THIRD_PARTY_LIB ${XGD_THIRD_PARTY_LIBS})
        include(${CMAKE_SOURCE_DIR}/cmake/build-${XGD_THIRD_PARTY_LIB}.cmake)
    endforeach ()
endfunction()

xgd_build_third_party()
