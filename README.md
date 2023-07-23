# Third party libraries for xgd's project

## "dev" branch
1. Source codes are organized as git submodules.
2. Build scripts rewritten in cmake are put under "examples/cmake" directory.
3. Patches for source codes are in "third_party-changes.patch" file.
4. Patch file need to be applied after recursive git clone, since submodules are origin repositories.

## "main" branch
1. Only a minimal set of source files is kept.
2. File "third_party-changes.patch" has already been applied.
