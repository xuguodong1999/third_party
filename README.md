# Third party libraries for xgd's project

## `dev` branch

* Source codes are organized as git submodules.
* Build scripts rewritten in cmake are put under [cmake](cmake) directory.
* Patches for source codes are in [patches](patches) sub directories.

Patch file need to be applied after recursive git clone, since submodules are original repositories.

```bash
# clean
git submodule foreach --recursive git reset . && git submodule foreach --recursive git checkout ./ && git submodule foreach --recursive git clean -df
# apply
rm -rf ./rdkit-src/rdkit/Code/RDGeneral/export.h
git apply --reject --whitespace=fix patches/third_party-changes.patch && cp -a patches/* ./ && rm -rf third_party-changes.patch
```

## `main` branch

* Only a minimal set of source files is kept.
* Patches in [patches](patches) have already been applied.

## Build status

Record compilers and cross-build platforms that work fine with unofficial customized cmake build scripts.

|                   | Windows              | Linux         | MacOS                |
|-------------------|----------------------|---------------|----------------------|
| msvc-14.38        | &check;              | _             | _                    |
| gcc-11.4.0        | _                    | &check;       | _                    |
| gcc-13.2.0        | _                    | &check;       | _                    |
| apple-clang-15    | _                    | _             | &check; (Xcode 15.4) |
| ndk-26.2.11394342 | &check;              | &check;       | &check;              |
| emscripten-3.1.56 | &check;              | &check;       | &check;              |
| mingw-gcc-11.2.0  | &check; (Qt bundled) | &check; (MXE) | _                    |

