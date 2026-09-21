mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build

cmake -GNinja ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_INSTALL_LIBDIR=lib ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBUILD_TESTING=ON ^
      -DBUILD_SHARED_LIBS=ON ^
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON ^
      ..
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1

REM Expected condition to be false: outgoing_args.error_invoked
REM Bundled test certs (tests/resources/*.crt) expired 2026-08-06; same tests already excluded on linux/osx.
set "EXCLUDE_TESTS_WIN=tls_client_channel_negotiation_success_mtls_tls13|incoming_tcp_sock_errors|tls_channel_echo_and_backpressure_test|tls_channel_shutdown_with_cache_test|tls_channel_shutdown_with_cache_window_update_after_shutdown_test|tls_server_multiple_connections|tls_channel_statistics_test|tls_certificate_chain_test"
ctest -E "%EXCLUDE_TESTS_WIN%" --output-on-failure
if errorlevel 1 exit 1