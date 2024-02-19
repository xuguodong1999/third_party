# Third party libraries for xgd's project

## "dev" branch

* Source codes are organized as git submodules.
* Build scripts rewritten in cmake are put under `./cmake` directory.
* Patches for source codes are in `./patches/**.patch` files.
* Patch file need to be applied after recursive git clone, since submodules are origin repositories.

## "main" branch

* Only a minimal set of source files is kept.
* Files `./patches/**.patch` has already been applied.

## Build status

Record compilers and cross-build platforms that work fine with newly written build script.

|                   | Windows              | Linux         | MacOS   |
|-------------------|----------------------|---------------|---------|
| msvc-14.38        | &check;              | _             | _       |
| gcc-11.4.0        | _                    | &check;       | _       |
| apple-clang-15    | _                    | _             | &check; |
| ndk-26.1.10909125 | &check;              | &check;       | &check; |
| emcc-3.1.51       | &check;              | &check;       | &check; |
| mingw-gcc-11.2.0  | &check; (Qt bundled) | &check; (MXE) | _       |

