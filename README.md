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

## Supported 3rdparty Libraries

| Library | Source |
| ---- | --- |
|avalontoolkit|http://sourceforge.net/projects/avalontoolkit/files/AvalonToolkit_1.2/AvalonToolkit_1.2.0.source.tar|
|benchmark|https://github.com/google/benchmark/archive/refs/tags/v1.7.1.tar.gz|
|boost|https://boostorg.jfrog.io/artifactory/main/release/1.81.0/source/boost_1_81_0.7z|
|coordgenlibs|https://github.com/schrodinger/coordgenlibs/archive/refs/tags/v3.0.1.tar.gz|
|cutlass|https://github.com/nvidia/cutlass/archive/refs/tags/v2.10.0.tar.gz|
|eigen3|https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz|
|freesasa|https://github.com/mittinatten/freesasa/releases/download/2.1.2/freesasa-2.1.2.zip|
|gtest|https://github.com/google/googletest/archive/refs/tags/release-1.12.1.tar.gz|
|inchi|https://www.inchi-trust.org/wp/download/106/INCHI-1-SRC.zip|
|lbfgs|https://github.com/yixuan/LBFGSpp/archive/refs/tags/v0.2.0.tar.gz|
|libpng|https://github.com/glennrp/libpng/archive/refs/tags/v1.6.39.tar.gz|
|libxml|https://github.com/GNOME/libxml2/archive/refs/tags/v2.10.3.tar.gz|
|maeparser|https://github.com/schrodinger/maeparser/archive/refs/tags/v1.3.0.tar.gz|
|ncnn|https://github.com/Tencent/ncnn/archive/refs/tags/20221128.tar.gz|
|openbabel|https://github.com/openbabel/openbabel/releases/download/openbabel-3-1-1/openbabel-3.1.1-source.tar.bz2|
|rapidjson|https://github.com/Tencent/rapidjson/archive/refs/tags/v1.1.0.tar.gz|
|rdkit|https://github.com/rdkit/rdkit/archive/refs/tags/Release_2022_09_4.tar.gz|
|RingDecomposerLib|https://github.com/rareylab/RingDecomposerLib/archive/refs/tags/v1.1.3_rdkit.tar.gz|
|rxcpp|https://github.com/ReactiveX/RxCpp/archive/refs/tags/v4.1.1.tar.gz|
|spdlog|https://github.com/gabime/spdlog/archive/refs/tags/v1.11.0.tar.gz|
|taskflow|https://github.com/taskflow/taskflow/archive/refs/tags/v3.4.0.tar.gz|
|yaehmop|https://github.com/greglandrum/yaehmop/archive/refs/tags/v2022.09.1.tar.gz|
|yoga|https://github.com/facebook/yoga/archive/refs/tags/v1.19.0.tar.gz|
|zlib|https://www.zlib.net/zlib-1.2.13.tar.gz|

## Not Fully Supported Libraries

| Library | Module |
| ---- | --- |
| boost | context |
| boost | coroutine |
| boost | fiber |
| boost | graph_parallel |
| boost | locale |
| boost | log |
| boost | mpi |
| boost | python |
| boost | test |
| ncnn | loongarch |
| ncnn | mips |
| ncnn | riscv |
| rdkit | Fuzz |
| rdkit | PgSQL |
| rdkit | RDBoost |

## C++ Source copy
```shell
find . -type f -empty > empty.log
grep -rIL . | xargs -I {} rm -rf "{}"
cat empty.log | xargs -I {} touch "{}" && rm -rf empty.log

# openbabel
pushd ./openbabel/include && rm -rf inchi LBFGS libxml iconv.h inchi_api.h LBFGS.h zconf.h zlib.h && popd
rm -rf ./openbabel/test/pdb_ligands_sdf ./openbabel/external ./openbabel/scripts
# boost
rm -rf ./boost/libs/json/bench/data ./boost/doc ./boost/status ./boost/libs/graph/test/weighted_matching.dat
find . -type d -wholename ./boost/*/doc | xargs -I {} rm -rf "{}"
# libxml2
rm -rf ./libxml2/doc ./libxml2/result ./libxml2/test
# others
rm -rf ./taskflow/3rd-party taskflow/docs ./cutlass/docs ./freesasa/tests/data

rm -rf ./rdkit/Docs/Notebooks
find . -type d -wholename ./rdkit/*/*testdata -o -wholename ./rdkit/*/*test_data -o -wholename ./rdkit/*/*testData | xargs -I {} rm -rf "{}"

# ls * -d | xargs -I {} zip -r {}.zip -9 {}
# find . -type f -size +3M
```
## API reference

```cmake

```
