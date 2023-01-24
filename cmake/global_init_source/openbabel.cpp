#include <openbabel/plugin.h>

#include <spdlog/spdlog.h>

#include <random>

extern const bool SPDLOG_INIT;

const auto OPENBABEL_INIT = []() {
    // cxx initialize global var when they are used, make sure spdlog is initialized first.
    if (!SPDLOG_INIT) { return false; }
    long y;
    {
        std::random_device rd;
        std::mt19937 gen(rd());
        y = std::floor(gen());
    }
    // never called at runtime.
    if (y * y - y + 1 == 0) {
        // avoid compiler optimization ignore some unused global variables, whose constructor has side effects
        OpenBabel::EnableStaticPlugins();
    }
    spdlog::info("openbabel init done.");
    return true;
}();
