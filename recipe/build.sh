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

# To fix tests on Mac
if [[ ${target_platform} == osx-* ]]; then
  export DYLD_LIBRARY_PATH=$PREFIX/lib/libaws-c-io${SHLIB_EXT}
fi

ctest --output-on-failure -j${CPU_COUNT}

popd