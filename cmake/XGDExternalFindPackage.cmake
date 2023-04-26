if (XGD_USE_OPENMP AND NOT ANDROID) # on android, openmp is always available
    find_package(OpenMP QUIET)
    if (NOT OpenMP_CXX_FOUND)
        set(XGD_USE_OPENMP OFF CACHE INTERNAL "" FORCE)
        message(WARNING "XGD_USE_OPENMP set to OFF:"
                " OpenMP_CXX_FOUND=\"${OpenMP_CXX_FOUND}\""
                " ANDROID=\"${ANDROID}\"")
    endif ()
endif ()

if (XGD_USE_CUDA)
    if (MSVC OR ((CMAKE_SYSTEM_NAME STREQUAL "Linux") AND (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")))
        find_package(CUDAToolkit QUIET)
        if (NOT CUDAToolkit_FOUND)
            set(XGD_USE_CUDA OFF CACHE INTERNAL "" FORCE)
            message(WARNING "XGD_USE_CUDA set to OFF:"
                    " CUDAToolkit_FOUND=\"${CUDAToolkit_FOUND}\"")
        endif ()
    else ()
        set(XGD_USE_CUDA OFF CACHE INTERNAL "" FORCE)
        message(WARNING "XGD_USE_CUDA set to OFF:"
                " MSVC=\"${MSVC}\""
                " CMAKE_CXX_COMPILER_ID=\"${CMAKE_CXX_COMPILER_ID}\""
                " CMAKE_SYSTEM_NAME=\"${CMAKE_SYSTEM_NAME}\"")
    endif ()
endif ()

if (XGD_USE_QT)
    find_package(QT NAMES Qt6 QUIET)
    if (QT_FOUND)
        find_package(Qt${QT_VERSION_MAJOR} COMPONENTS ${XGD_QT_MODULES} QUIET)
        foreach (_XGD_QT_MODULE ${XGD_QT_MODULES})
            if (NOT ${Qt${QT_VERSION_MAJOR}${_XGD_QT_MODULE}_FOUND})
                set(XGD_USE_QT OFF CACHE INTERNAL "" FORCE)
                set(_XGD_QT_MODULE_FOUND "Qt${QT_VERSION_MAJOR}${_XGD_QT_MODULE}_FOUND")
                message(WARNING "XGD_USE_QT set to OFF:"
                        " QT_FOUND=\"${QT_FOUND}\""
                        " CMAKE_PREFIX_PATH=\"${CMAKE_PREFIX_PATH}\""
                        " ${_XGD_QT_MODULE_FOUND}=\"${${_XGD_QT_MODULE_FOUND}}\"")
                break()
            endif ()
        endforeach ()
    else ()
        set(XGD_USE_QT OFF CACHE INTERNAL "" FORCE)
        message(WARNING "XGD_USE_QT set to OFF:"
                " QT_FOUND=\"${QT_FOUND}\""
                " CMAKE_PREFIX_PATH=\"${CMAKE_PREFIX_PATH}\"")
    endif ()
endif ()

if (XGD_USE_VK)
    find_package(Vulkan COMPONENTS shaderc_combined QUIET)
    if (ANDROID AND NOT Vulkan_shaderc_combined_LIBRARY)
        find_package(Vulkan QUIET)
        while (1)
            if (NOT Vulkan_FOUND)
                break()
            endif ()
            if (ANDROID_NDK AND NOT Vulkan_GLSLC_EXECUTABLE)
                file(GLOB GLSLC_FOLDERS ${ANDROID_NDK}/shader-tools/*)
                find_program(Vulkan_GLSLC_EXECUTABLE glslc HINTS ${GLSLC_FOLDERS} QUIET)
            endif ()
            if (NOT Vulkan_GLSLC_EXECUTABLE)
                break()
            endif ()
            if (ANDROID_NDK AND NOT Vulkan_shaderc_combined_LIBRARY)
                set(_XGD_ANDROID_SHADERC_SOURCE_DIR ${ANDROID_NDK}/sources/third_party/shaderc)
                find_library(Vulkan_shaderc_combined_LIBRARY
                        HINTS ${_XGD_ANDROID_SHADERC_SOURCE_DIR}/libs/${ANDROID_STL}/${ANDROID_ABI}
                        NAMES libshaderc.a
                        QUIET)
                set(Vulkan_ANDROID_INCLUDE_DIR ${_XGD_ANDROID_SHADERC_SOURCE_DIR}/third_party
                        ${_XGD_ANDROID_SHADERC_SOURCE_DIR}/third_party/glslang
                        CACHE INTERNAL "shaderc include directory" FORCE)
            endif ()
            break()
        endwhile ()
    endif ()
    if (NOT (Vulkan_FOUND AND Vulkan_GLSLC_EXECUTABLE AND Vulkan_shaderc_combined_LIBRARY))
        set(XGD_USE_VK OFF CACHE INTERNAL "" FORCE)
        message(WARNING "XGD_USE_VK set to OFF:"
                " Vulkan_FOUND=\"${Vulkan_FOUND}\""
                " ANDROID_NDK=\"${ANDROID_NDK}\""
                " ANDROID_STL=\"${ANDROID_STL}\""
                " ANDROID_ABI=\"${ANDROID_ABI}\""
                " Vulkan_GLSLC_EXECUTABLE=\"${Vulkan_GLSLC_EXECUTABLE}\""
                " Vulkan_shaderc_combined_LIBRARY=\"${Vulkan_shaderc_combined_LIBRARY}\"")
    endif ()
endif ()

if (XGD_USE_TORCH)
    find_package(Torch QUIET)
    if (NOT Torch_FOUND)
        set(XGD_USE_TORCH OFF CACHE INTERNAL "" FORCE)
        message(WARNING "XGD_USE_TORCH set to OFF:"
                " Torch_DIR=\"${Torch_DIR}\""
                " Torch_FOUND=\"${Torch_FOUND}\"")
    else ()
        set(TORCH_INCLUDE_DIRS ${TORCH_INCLUDE_DIRS} CACHE INTERNAL "" FORCE)
        set(TORCH_LIBRARIES ${TORCH_LIBRARIES} CACHE INTERNAL "" FORCE)
    endif ()
endif ()

if (XGD_USE_OPENCV)
    find_package(OpenCV QUIET)
    if (NOT OpenCV_FOUND)
        set(XGD_USE_OPENCV OFF CACHE INTERNAL "" FORCE)
        message(WARNING "XGD_USE_OPENCV set to OFF:"
                " OpenCV_DIR=\"${OpenCV_DIR}\""
                " OpenCV_FOUND=\"${OpenCV_FOUND}\"")
    endif ()
endif ()
