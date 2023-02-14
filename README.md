# deps for xgd-project

**deps for xgd-project** is a repo to make cross-platform integration of some 3rdparty libraries easier, especially for
cross-compiling on android, ios and wasm.

Instead of using `find_package` to find pre-installed libraries, **deps for xgd-project** is aimed at source integration.

Normally, **deps for xgd-project** is used as a git submodule. Once called by cmake from `add_subdirectory`, it will generate all
targets but exclude from cmake `all` variable. A target will not be built from source until manually linked.

Typical usage:

```cmake
# CMakeLists.txt
project(hello-world)

# expose a "XGD_DEPS_DIR" var for deps to find root
set(XGD_DEPS_DIR /path/to/deps)
# expose a "XGD_GENERATED_DIR" var for deps to generated export header and some assets
set(XGD_GENERATED_DIR ${CMAKE_BINARY_DIR}/generated)

include(${XGD_DEPS_DIR}/cmake/api_deps_util.cmake)
xgd_setup_compile_options()
xgd_check_compiler_arch()

add_subdirectory(${XGD_DEPS_DIR})
add_executable(${PROJECT_NAME} main.cpp) # add your codes here

# include related cmake function
include(${XGD_DEPS_DIR}/cmake/api_deps_link.cmake)
# link Boost::iostreams, Boost::serialization to hello-world
xgd_link_boost(${PROJECT_NAME} COMPONENTS iostreams serialization)
# link OpenBabel to hello-world
xgd_link_openbabel(${PROJECT_NAME})
# use header only libraries: rxcpp and json
xgd_use_header(${PROJECT_NAME} PRIVATE rxcpp eigen)
# use header only boost modules
xgd_use_header(${PROJECT_NAME} PRIVATE boost)
# ...
```

Most 3rdparty build scripts are rewritten in CMake to support building as subprojects.

## Integrated 3rdparty Libraries

| Library           | Source                                                                                                  |
|-------------------|---------------------------------------------------------------------------------------------------------|
| ade               | https://github.com/opencv/ade/archive/refs/tags/v0.1.2a.tar.gz                                          |
| armadillo         | http://sourceforge.net/projects/arma/files/armadillo-11.4.4.tar.xz                                      |
| avalontoolkit     | http://sourceforge.net/projects/avalontoolkit/files/AvalonToolkit_1.2/AvalonToolkit_1.2.0.source.tar    |
| benchmark         | https://github.com/google/benchmark/archive/refs/tags/v1.7.1.tar.gz                                     |
| boost             | https://boostorg.jfrog.io/artifactory/main/release/1.81.0/source/boost_1_81_0.7z                        |
| cereal            | https://github.com/USCiLab/cereal/archive/refs/tags/v1.3.2.tar.gz                                       |
| coordgenlibs      | https://github.com/schrodinger/coordgenlibs/archive/refs/tags/v3.0.1.tar.gz                             |
| cutlass           | https://github.com/nvidia/cutlass/archive/refs/tags/v2.10.0.tar.gz                                      |
| eigen3            | https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz                                    |
| ensmallen         | https://ensmallen.org/files/ensmallen-2.19.1.tar.gz                                                     |
| freesasa          | https://github.com/mittinatten/freesasa/releases/download/2.1.2/freesasa-2.1.2.zip                      |
| gtest             | https://github.com/google/googletest/archive/refs/tags/release-1.12.1.tar.gz                            |
| inchi             | https://www.inchi-trust.org/wp/download/106/INCHI-1-SRC.zip                                             |
| lbfgs             | https://github.com/yixuan/LBFGSpp/archive/refs/tags/v0.2.0.tar.gz                                       |
| libpng            | https://github.com/glennrp/libpng/archive/refs/tags/v1.6.39.tar.gz                                      |
| libxml            | https://github.com/GNOME/libxml2/archive/refs/tags/v2.10.3.tar.gz                                       |
| maeparser         | https://github.com/schrodinger/maeparser/archive/refs/tags/v1.3.0.tar.gz                                |
| mlpack            | https://github.com/mlpack/mlpack/archive/refs/tags/4.0.1.tar.gz                                         |
| ncnn              | https://github.com/Tencent/ncnn/archive/refs/tags/20221128.tar.gz                                       |
| openbabel         | https://github.com/openbabel/openbabel/releases/download/openbabel-3-1-1/openbabel-3.1.1-source.tar.bz2 |
| opencv            | https://github.com/opencv/opencv/archive/refs/tags/4.7.0.tar.gz                                         |
| rapidjson         | https://github.com/Tencent/rapidjson/archive/012be8528783cdbf4b7a9e64f78bd8f056b97e24.zip               |
| rdkit             | https://github.com/rdkit/rdkit/archive/refs/tags/Release_2022_09_4.tar.gz                               |
| RingDecomposerLib | https://github.com/rareylab/RingDecomposerLib/archive/refs/tags/v1.1.3_rdkit.tar.gz                     |
| rxcpp             | https://github.com/ReactiveX/RxCpp/archive/refs/tags/v4.1.1.tar.gz                                      |
| spdlog            | https://github.com/gabime/spdlog/archive/refs/tags/v1.11.0.tar.gz                                       |
| stb               | https://github.com/nothings/stb/archive/5736b15f7ea0ffb08dd38af21067c314d6a3aae9.zip                    |
| taskflow          | https://github.com/taskflow/taskflow/archive/refs/tags/v3.4.0.tar.gz                                    |
| yaehmop           | https://github.com/greglandrum/yaehmop/archive/refs/tags/v2022.09.1.tar.gz                              |
| yoga              | https://github.com/facebook/yoga/archive/refs/tags/v1.19.0.tar.gz                                       |
| zlib              | https://www.zlib.net/zlib-1.2.13.tar.gz                                                                 |

## Not Supported Modules

| Library | Module         |
|---------|----------------|
| boost   | context        |
| boost   | coroutine      |
| boost   | fiber          |
| boost   | graph_parallel |
| boost   | locale         |
| boost   | log            |
| boost   | mpi            |
| boost   | python         |
| boost   | test           |
| ncnn    | loongarch      |
| ncnn    | mips           |
| ncnn    | riscv          |
| opencv  | dnn            |
| opencv  | highgui        |
| opencv  | videoio        |
| rdkit   | Fuzz           |
| rdkit   | PgSQL          |
| rdkit   | RDBoost        |

## C++ Source copy
```shell
# unzip all downloads
mkdir -p ../tmp/avalontoolkit/
tar -xvf ade-0.1.2a.tar.gz -C ../tmp
tar -xvf armadillo-11.4.4.tar.xz -C ../tmp/
tar -xvf AvalonToolkit_1.2.0.source.tar -C ../tmp/avalontoolkit/
tar -xvf benchmark-1.7.1.tar.gz -C ../tmp/
tar -xvf boost_1_81_0.tar.gz -C ../tmp/
tar -xvf cereal-1.3.2.tar.gz -C ../tmp/  
tar -xvf coordgenlibs-3.0.1.tar.gz -C ../tmp/
tar -xvf cutlass-2.10.0.tar.gz -C ../tmp/
tar -xvf eigen-3.4.0.tar.gz -C ../tmp/
tar -xvf ensmallen-2.19.1.tar.gz -C ../tmp/
tar -xvf googletest-release-1.12.1.tar.gz -C ../tmp/
tar -xvf LBFGSpp-0.2.0.tar.gz -C ../tmp/
tar -xvf libpng-1.6.39.tar.gz -C ../tmp/
tar -xvf libxml2-2.10.3.tar.gz -C ../tmp/
tar -xvf maeparser-1.3.0.tar.gz -C ../tmp/
tar -xvf mlpack-4.0.1.tar.gz -C ../tmp/
tar -xvf ncnn-20221128.tar.gz -C ../tmp/
tar -xvf openbabel-3.1.1-source.tar.bz2 -C ../tmp/
tar -xvf opencv-4.7.0.tar.gz -C ../tmp/
tar -xvf rdkit-Release_2022_09_4.tar.gz -C ../tmp/
tar -xvf RingDecomposerLib-1.1.3_rdkit.tar.gz -C ../tmp/
tar -xvf RxCpp-4.1.1.tar.gz -C ../tmp/
tar -xvf spdlog-1.11.0.tar.gz -C ../tmp/
tar -xvf taskflow-3.4.0.tar.gz -C ../tmp/
tar -xvf yaehmop-2022.09.1.tar.gz -C ../tmp/
tar -xvf yoga-1.19.0.tar.gz -C ../tmp/
tar -xvf zlib-1.2.13.tar.gz -C ../tmp/
unzip freesasa-2.1.2.zip -d ../tmp/
unzip INCHI-1-SRC.zip -d ../tmp/
unzip rapidjson-012be8528783cdbf4b7a9e64f78bd8f056b97e24.zip -d ../tmp/
unzip stb-5736b15f7ea0ffb08dd38af21067c314d6a3aae9.zip -d ../tmp/

# rename dir
mv ade-0.1.2a ade
mv armadillo-11.4.4 armadillo
mv benchmark-1.7.1 benchmark
mv boost_1_81_0 boost
mv cereal-1.3.2 cereal
mv coordgenlibs-3.0.1 coordgen
mv cutlass-2.10.0 cutlass
mv eigen-3.4.0 eigen
mv ensmallen-2.19.1 ensmallen
mv freesasa-2.1.2 freesasa
mv googletest-release-1.12.1 gtest
mv INCHI-1-SRC inchi
mv LBFGSpp-0.2.0 lbfgs
mv libpng-1.6.39 libpng
mv libxml2-2.10.3 libxml2
mv maeparser-1.3.0 maeparser
mv mlpack-4.0.1 mlpack
mv ncnn-20221128 ncnn
mv openbabel-3.1.1 openbabel
mv opencv-4.7.0 opencv
mv rapidjson-012be8528783cdbf4b7a9e64f78bd8f056b97e24 rapidjson
mv rdkit-Release_2022_09_4 rdkit
mv RingDecomposerLib-1.1.3_rdkit ringdecomposerlib
mv RxCpp-4.1.1 rxcpp
mv spdlog-1.11.0 spdlog
mv stb-5736b15f7ea0ffb08dd38af21067c314d6a3aae9 stb
mv taskflow-3.4.0 taskflow
mv yaehmop-2022.09.1 yaehmop
mv yoga-1.19.0 yoga
mv zlib-1.2.13 zlib

# remove large files
find . -type f -empty > empty.log
grep -rIL . --exclude-dir=Material | xargs -I {} rm -rf "{}"
cat empty.log | xargs -I {} touch "{}" && rm -rf empty.log

## openbabel
pushd ./openbabel/include && rm -rf inchi LBFGS libxml iconv.h inchi_api.h LBFGS.h zconf.h zlib.h && popd
rm -rf ./openbabel/test/pdb_ligands_sdf ./openbabel/external ./openbabel/scripts ./openbabel/src/formats/libinchi
## boost
rm -rf ./boost/libs/json/bench/data ./boost/doc ./boost/status ./boost/libs/graph/test/weighted_matching.dat
find . -type d -wholename ./boost/*/doc | xargs -I {} rm -rf "{}"
## libxml2
rm -rf ./libxml2/doc ./libxml2/result ./libxml2/test
## rdkit
rm -rf ./rdkit/Docs/Notebooks ./rdkit/Contrib/NIBRSubstructureFilters/FilterSet_NIBR2019_wPubChemExamples.html
find . -type d -wholename ./rdkit/*/*testdata -o -wholename ./rdkit/*/*test_data -o -wholename ./rdkit/*/*testData | xargs -I {} rm -rf "{}"
## others
rm -rf ./taskflow/3rd-party taskflow/docs ./cutlass/docs ./freesasa/tests/data ./ncnn/src/stb_*.h
rm -rf ./mlpack/src/mlpack/tests/data
rm -rf ./opencv/3rdparty ./opencv/doc


# encoding
find . -type f -name *.c -o -name *.cpp -o -name *.cc -o -name *.h -o -name *.hh -o -name *.hpp | xargs dos2unix
## TODO: using VSCode, change ./openbabel/data/ghemical.prm from windows 1252 to UTF-8
pushd ./openbabel/data && find . -type f | xargs dos2unix && popd

# rename dir
ls * -d | xargs -I{} mkdir {}-src
ls !(*-src) -d | xargs -I{} mv {} {}-src/

# debug only
# tree -L 2
# ls * -d | xargs -I {} zip -r {}.zip -9 {}
# find . -type f -size +3M
# pushd ./openbabel/data && find . -type f | xargs dos2unix && popd

```
## API reference

```cmake

```
