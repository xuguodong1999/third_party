#include <spdlog/spdlog.h>

#ifdef __ANDROID__
#include <spdlog/sinks/android_sink.h>
#endif

extern const bool SPDLOG_INIT;

const bool SPDLOG_INIT = []() {
#ifdef __ANDROID__
    auto default_logger = spdlog::android_logger_mt("spdlog");
    spdlog::set_default_logger(default_logger);
#else
    spdlog::set_pattern("[%Y-%m-%d %T.%e] [%l] [thread %-6t] %v");
    spdlog::info("spdlog init done.");
#endif
    return true;
}();
