project(examples_asio)
set(SUB_PROJECT_IDS
        cpp11/http/server
        ## cpp11/type_erasure
        ## cpp20/type_erasure
)
set(SUB_PROJECT_FILES
        cpp11/invocation/prioritised_handlers.cpp
        cpp11/timers/time_t_timer.cpp
        cpp11/iostreams/http_client.cpp
        cpp11/parallel_group/wait_for_one.cpp
        cpp11/parallel_group/wait_for_one_success.cpp
        cpp11/parallel_group/ranged_wait_for_all.cpp
        cpp11/parallel_group/wait_for_one_error.cpp
        cpp11/parallel_group/wait_for_all.cpp
        cpp11/local/iostream_client.cpp
        cpp11/local/stream_server.cpp
        ## cpp11/local/fd_passing_stream_client.cpp
        cpp11/local/stream_client.cpp
        ## cpp11/local/fd_passing_stream_server.cpp
        cpp11/local/connect_pair.cpp
        cpp11/nonblocking/third_party_lib.cpp
        # cpp11/spawn/echo_server.cpp
        # cpp11/spawn/parallel_grep.cpp
        cpp11/buffers/reference_counted.cpp
        cpp11/deferred/deferred_2.cpp
        cpp11/deferred/deferred_1.cpp
        cpp11/operations/composed_2.cpp
        cpp11/operations/composed_1.cpp
        cpp11/operations/composed_7.cpp
        cpp11/operations/composed_8.cpp
        cpp11/operations/composed_3.cpp
        cpp11/operations/composed_4.cpp
        cpp11/operations/composed_5.cpp
        cpp11/operations/composed_6.cpp
        cpp11/handler_tracking/async_tcp_echo_server.cpp
        cpp11/futures/daytime_client.cpp
        cpp11/allocation/server.cpp
        cpp11/ssl/client.cpp
        cpp11/ssl/server.cpp
        cpp11/chat/chat_client.cpp
        cpp11/chat/chat_server.cpp
        ## cpp11/fork/process_per_connection.cpp
        ## cpp11/fork/daemon.cpp
        cpp11/files/blocking_file_copy.cpp
        cpp11/files/async_file_copy.cpp
        cpp11/socks4/sync_client.cpp
        cpp11/multicast/receiver.cpp
        cpp11/multicast/sender.cpp
        cpp11/echo/async_tcp_echo_server.cpp
        cpp11/echo/blocking_udp_echo_client.cpp
        cpp11/echo/blocking_tcp_echo_server.cpp
        cpp11/echo/blocking_tcp_echo_client.cpp
        cpp11/echo/blocking_udp_echo_server.cpp
        cpp11/echo/async_udp_echo_server.cpp
        cpp11/executors/actor.cpp
        cpp11/executors/fork_join.cpp
        cpp11/executors/bank_account_1.cpp
        cpp11/executors/priority_scheduler.cpp
        cpp11/executors/pipeline.cpp
        cpp11/executors/bank_account_2.cpp
        cpp11/timeouts/blocking_tcp_client.cpp
        cpp11/timeouts/blocking_udp_client.cpp
        cpp11/timeouts/blocking_token_tcp_client.cpp
        cpp11/timeouts/async_tcp_client.cpp
        cpp11/timeouts/server.cpp
        cpp03/invocation/prioritised_handlers.cpp
        cpp03/tutorial/daytime3/server.cpp
        cpp03/tutorial/daytime7/server.cpp
        cpp03/tutorial/daytime2/server.cpp
        cpp03/tutorial/timer5/timer.cpp
        cpp03/tutorial/daytime6/server.cpp
        cpp03/tutorial/timer3/timer.cpp
        cpp03/tutorial/timer4/timer.cpp
        cpp03/tutorial/daytime4/client.cpp
        cpp03/tutorial/timer2/timer.cpp
        cpp03/tutorial/timer1/timer.cpp
        cpp03/tutorial/daytime5/server.cpp
        cpp03/tutorial/daytime1/client.cpp
        cpp03/timers/time_t_timer.cpp
        cpp03/iostreams/daytime_client.cpp
        cpp03/iostreams/daytime_server.cpp
        cpp03/iostreams/http_client.cpp
        cpp03/local/iostream_client.cpp
        cpp03/local/stream_server.cpp
        cpp03/local/stream_client.cpp
        cpp03/local/connect_pair.cpp
        cpp03/nonblocking/third_party_lib.cpp
        # cpp03/serialization/client.cpp
        # cpp03/serialization/server.cpp
        cpp03/icmp/ping.cpp
        cpp03/services/daytime_client.cpp
        # cpp03/services/logger_service.cpp
        # cpp03/spawn/echo_server.cpp
        # cpp03/spawn/parallel_grep.cpp
        cpp03/buffers/reference_counted.cpp
        cpp03/http/client/async_client.cpp
        cpp03/http/client/sync_client.cpp
        cpp03/allocation/server.cpp
        cpp03/ssl/client.cpp
        cpp03/ssl/server.cpp
        cpp03/chat/chat_client.cpp
        cpp03/chat/posix_chat_client.cpp
        cpp03/chat/chat_server.cpp
        ## cpp03/fork/process_per_connection.cpp
        ## cpp03/fork/daemon.cpp
        cpp03/socks4/sync_client.cpp
        # cpp03/windows/transmit_file.cpp
        cpp03/multicast/receiver.cpp
        cpp03/multicast/sender.cpp
        cpp03/echo/async_tcp_echo_server.cpp
        cpp03/echo/blocking_udp_echo_client.cpp
        cpp03/echo/blocking_tcp_echo_server.cpp
        cpp03/echo/blocking_tcp_echo_client.cpp
        cpp03/echo/blocking_udp_echo_server.cpp
        cpp03/echo/async_udp_echo_server.cpp
        cpp03/porthopper/client.cpp
        cpp03/porthopper/server.cpp
        cpp03/timeouts/blocking_tcp_client.cpp
        cpp03/timeouts/blocking_udp_client.cpp
        cpp03/timeouts/blocking_token_tcp_client.cpp
        cpp03/timeouts/async_tcp_client.cpp
        cpp03/timeouts/server.cpp
        cpp20/channels/throttling_proxy.cpp
        cpp20/coroutines/echo_server_with_deferred.cpp
        cpp20/coroutines/echo_server_with_as_tuple_default.cpp
        cpp20/coroutines/echo_server_with_default.cpp
        cpp20/coroutines/echo_server.cpp
        cpp20/coroutines/echo_server_with_deferred_default.cpp
        cpp20/coroutines/chat_server.cpp
        cpp20/coroutines/echo_server_with_as_single_default.cpp
        cpp20/coroutines/timeout.cpp
        cpp20/coroutines/refactored_echo_server.cpp
        cpp20/operations/composed_2.cpp
        cpp20/operations/composed_1.cpp
        cpp20/operations/callback_wrapper.cpp
        cpp20/operations/composed_7.cpp
        cpp20/operations/composed_8.cpp
        cpp20/operations/composed_3.cpp
        cpp20/operations/c_callback_wrapper.cpp
        cpp20/operations/composed_4.cpp
        cpp20/operations/composed_5.cpp
        cpp20/operations/composed_6.cpp
        cpp17/coroutines_ts/echo_server_with_as_tuple_default.cpp
        cpp17/coroutines_ts/echo_server_with_default.cpp
        cpp17/coroutines_ts/echo_server.cpp
        cpp17/coroutines_ts/chat_server.cpp
        # cpp17/coroutines_ts/range_based_for.cpp
        cpp17/coroutines_ts/echo_server_with_as_single_default.cpp
        cpp17/coroutines_ts/refactored_echo_server.cpp
        cpp14/iostreams/http_client.cpp
        cpp14/parallel_group/wait_for_one.cpp
        cpp14/parallel_group/wait_for_one_success.cpp
        cpp14/parallel_group/parallel_sort.cpp
        cpp14/parallel_group/ranged_wait_for_all.cpp
        cpp14/parallel_group/wait_for_one_error.cpp
        cpp14/parallel_group/wait_for_all.cpp
        cpp14/deferred/deferred_2.cpp
        cpp14/deferred/deferred_6.cpp
        cpp14/deferred/deferred_5.cpp
        cpp14/deferred/deferred_1.cpp
        cpp14/deferred/deferred_4.cpp
        cpp14/deferred/deferred_3.cpp
        cpp14/deferred/deferred_7.cpp
        cpp14/operations/composed_2.cpp
        cpp14/operations/composed_1.cpp
        cpp14/operations/callback_wrapper.cpp
        cpp14/operations/composed_7.cpp
        cpp14/operations/composed_8.cpp
        cpp14/operations/composed_3.cpp
        cpp14/operations/c_callback_wrapper.cpp
        cpp14/operations/composed_4.cpp
        cpp14/operations/composed_5.cpp
        cpp14/operations/composed_6.cpp
        cpp14/executors/actor.cpp
        cpp14/executors/async_1.cpp
        cpp14/executors/fork_join.cpp
        cpp14/executors/bank_account_1.cpp
        cpp14/executors/priority_scheduler.cpp
        cpp14/executors/pipeline.cpp
        cpp14/executors/async_2.cpp
        cpp14/executors/bank_account_2.cpp)
foreach (SUB_PROJECT_ID ${SUB_PROJECT_IDS})
    set(SUB_PROJECT_NAME ${SUB_PROJECT_ID})
    string(REGEX REPLACE "/" "_" SUB_PROJECT_NAME "${SUB_PROJECT_ID}")
    set(SUB_PROJECT_NAME ${PROJECT_NAME}_${SUB_PROJECT_NAME})
    xgd_add_executable(${SUB_PROJECT_NAME} SRC_DIRS ${SUB_PROJECT_ID})
    xgd_link_libraries(${SUB_PROJECT_NAME} PRIVATE boost_asio boost_logic)
endforeach ()
foreach (SUB_PROJECT_ID ${SUB_PROJECT_FILES})
    set(SUB_PROJECT_NAME ${SUB_PROJECT_ID})
    string(REGEX REPLACE "/" "_" SUB_PROJECT_NAME "${SUB_PROJECT_ID}")
    string(REGEX REPLACE ".cpp" "" SUB_PROJECT_NAME "${SUB_PROJECT_NAME}")
    set(SUB_PROJECT_NAME ${PROJECT_NAME}_${SUB_PROJECT_NAME})
    xgd_add_executable(${SUB_PROJECT_NAME} SRC_FILES ${SUB_PROJECT_ID})
    xgd_link_libraries(${SUB_PROJECT_NAME} PRIVATE boost_asio)
endforeach ()


xgd_link_libraries(${PROJECT_NAME}_cpp11_local_connect_pair PRIVATE boost_thread)
xgd_link_libraries(${PROJECT_NAME}_cpp03_tutorial_timer5_timer PRIVATE boost_thread)
xgd_link_libraries(${PROJECT_NAME}_cpp03_local_connect_pair PRIVATE boost_thread)
xgd_link_libraries(${PROJECT_NAME}_cpp03_services_daytime_client PRIVATE boost_thread)
# xgd_link_libraries(${PROJECT_NAME}_cpp03_spawn_parallel_grep PRIVATE boost_thread)
xgd_link_libraries(${PROJECT_NAME}_cpp03_http_server2 PRIVATE boost_thread)
xgd_link_libraries(${PROJECT_NAME}_cpp03_http_server3 PRIVATE boost_thread)
xgd_link_libraries(${PROJECT_NAME}_cpp03_chat_chat_client PRIVATE boost_thread)
xgd_link_libraries(${PROJECT_NAME}_cpp03_echo_blocking_tcp_echo_server PRIVATE boost_thread)
xgd_link_libraries(${PROJECT_NAME}_cpp14_parallel_group_parallel_sort PRIVATE boost_thread)
xgd_link_libraries(${PROJECT_NAME}_cpp03_timeouts_blocking_tcp_client PRIVATE boost_lambda)
xgd_link_libraries(${PROJECT_NAME}_cpp03_timeouts_blocking_tcp_client PRIVATE boost_lambda)
xgd_link_libraries(${PROJECT_NAME}_cpp03_porthopper_client PRIVATE boost_lambda)

function(xgd_make_asio_executable TARGET OUTPUT_DIR OUTPUT_NAME)
    set_target_properties(${TARGET} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_DIR})
    set_target_properties(${TARGET} PROPERTIES OUTPUT_NAME ${OUTPUT_NAME})
    xgd_link_libraries(${TARGET} PRIVATE boost_asio_ssl)
    if (EMSCRIPTEN)
        xgd_emcc_link_rawfs_net(${TARGET})
    endif ()
endfunction()

# cpp03_ssl certificate file
set(CPP03_SSL_RUNTIME_DIR ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}_cpp03_ssl)
set(CERTIFICATE_FILES ca.pem dh4096.pem server.pem)
foreach (FILE_NAME ${CERTIFICATE_FILES})
    configure_file(
            ${CMAKE_CURRENT_SOURCE_DIR}/cpp03/ssl/${FILE_NAME}
            ${CPP03_SSL_RUNTIME_DIR}/${FILE_NAME}
    )
endforeach ()
xgd_make_asio_executable(${PROJECT_NAME}_cpp03_ssl_server ${CPP03_SSL_RUNTIME_DIR} server)
xgd_make_asio_executable(${PROJECT_NAME}_cpp03_ssl_client ${CPP03_SSL_RUNTIME_DIR} client)

# cpp11_ssl certificate file
set(CPP11_SSL_RUNTIME_DIR ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}_cpp11_ssl)
set(CERTIFICATE_FILES ca.pem dh4096.pem server.pem)
foreach (FILE_NAME ${CERTIFICATE_FILES})
    configure_file(
            ${CMAKE_CURRENT_SOURCE_DIR}/cpp11/ssl/${FILE_NAME}
            ${CPP11_SSL_RUNTIME_DIR}/${FILE_NAME}
    )
endforeach ()
xgd_make_asio_executable(${PROJECT_NAME}_cpp11_ssl_server ${CPP11_SSL_RUNTIME_DIR} server)
xgd_make_asio_executable(${PROJECT_NAME}_cpp11_ssl_client ${CPP11_SSL_RUNTIME_DIR} client)

# windows debug: try link system ssl
#function(xgd_link_system_openssl TARGET)
#    set(SYS_OPENSSL_ROOT C:/Shared/msvc2022_64/openssl)
#    target_link_libraries(${TARGET} PRIVATE
#            ${SYS_OPENSSL_ROOT}/lib/libcrypto.lib
#            ${SYS_OPENSSL_ROOT}/lib/libssl.lib crypt32)
#    target_include_directories(${TARGET} PRIVATE ${SYS_OPENSSL_ROOT}/include)
#endfunction()
#xgd_link_system_openssl(${PROJECT_NAME}_cpp11_ssl_server)
#xgd_link_system_openssl(${PROJECT_NAME}_cpp11_ssl_client)

# example
xgd_add_executable(${PROJECT_NAME}
        SRC_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR})
xgd_link_libraries(${PROJECT_NAME} PRIVATE boost_asio_ssl spdlog)
if (EMSCRIPTEN)
    set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".html")
endif ()
