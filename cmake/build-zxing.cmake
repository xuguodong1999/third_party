# zxing
set(ROOT_DIR ${XGD_THIRD_PARTY_DIR}/zxing-src/zxing/core)
set(INC_DIR ${ROOT_DIR}/src)
set(SRC_DIR ${ROOT_DIR}/src)

set(GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/zxing/include)
configure_file(${ROOT_DIR}/ZXVersion.h.in ${GEN_DIR}/ZXVersion.h)

xgd_add_library(ZXing STATIC
        SRC_DIRS ${SRC_DIR}
        ${SRC_DIR}/aztec
        ${SRC_DIR}/datamatrix
        ${SRC_DIR}/libzueci
        ${SRC_DIR}/maxicode
        ${SRC_DIR}/oned
        ${SRC_DIR}/pdf417
        ${SRC_DIR}/qrcode
        INCLUDE_DIRS ${INC_DIR} ${GEN_DIR})

add_library(ZXing::Core ALIAS ZXing)
