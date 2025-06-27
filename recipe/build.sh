#!/bin/bash

set -ex

mkdir build
pushd build
cmake ${CMAKE_ARGS} -GNinja \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DENABLE_TESTING=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  ..

cmake --build . --config Release --target install

if [[ ${target_platform} == osx-* ]]; then
  # Following tests demands provide password to root.
  EXCLUDE_ROOT_TESTS_APPLE="\
  test_concurrent_cert_import|\
  test_duplicate_cert_import|\
  tls_channel_echo_and_backpressure_test|\
  tls_channel_shutdown_with_cache_test|\
  tls_channel_shutdown_with_cache_window_update_after_shutdown_test|\
  tls_server_multiple_connections|\
  tls_server_hangup_during_negotiation|\
  test_pkcs8_import|\
  tls_channel_statistics_test|\
  tls_certificate_chain_test"

  # Failed to load shared library at path "../libaws-c-io.so" <- wrong dynamic lib format on macos hardcoded in test
  # https://github.com/awslabs/aws-c-io/blob/ee7925a345c336b9a9c2f6843422297c5f2a7b0f/tests/shared_library_test.c#L16
  EXCLUDE_DYLIB_TESTS_APPLE="\
  shared_library_open_success|\
  shared_library_find_function_failure|\
  shared_library_find_function_success"

  EXCLUDE_TEST_APPLE="${EXCLUDE_ROOT_TESTS_APPLE}|${EXCLUDE_DYLIB_TESTS_APPLE}"
  ctest -E "$EXCLUDE_TEST_APPLE" --output-on-failure -j${CPU_COUNT}
else
  ctest --output-on-failure -j${CPU_COUNT}
fi

popd