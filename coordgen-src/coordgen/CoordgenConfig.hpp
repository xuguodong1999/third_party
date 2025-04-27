#pragma once

#if 0
#ifndef STATIC_COORDGEN

#ifdef WIN32
#ifdef IN_COORDGEN
#define EXPORT_COORDGEN __declspec(dllexport)
#else
#define EXPORT_COORDGEN __declspec(dllimport)
#endif // IN_COORDGEN

#else

#define EXPORT_COORDGEN __attribute__((visibility("default")))

#endif // WIN32

#else

#define EXPORT_COORDGEN

#endif // STATIC_COORDGEN
#endif
#include <coordgenlibs_export.hpp>

#ifndef EXPORT_COORDGEN
#define EXPORT_COORDGEN COORDGENLIBS_EXPORT
#endif
