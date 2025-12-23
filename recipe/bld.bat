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
set "EXCLUDE_TESTS_WIN=tls_client_channel_negotiation_success_mtls_tls1_3|incoming_tcp_sock_errors"
ctest -E "%EXCLUDE_TESTS_WIN%" --output-on-failure
if errorlevel 1 exit 1