#!/bin/sh

set -e

root=$(pwd)

mkdir -p $root/build/native

if [ ! -d $root/sleef-native ]; then
    cd $root/build/native
    mkdir -p sleef
    cd sleef
    export CC= CXX=
    cmake $root/third_party/sleef -DBUILD_LIBM=OFF -DBUILD_DFT=OFF -DBUILD_QUAD=OFF -DBUILD_GNUABI_LIBS=OFF -DBUILD_TESTS=OFF
    make -j$(nproc) mkalias mkdisp mkmasked_gnuabi mkrename mkrename_gnuabi
    mkdir -p $root/sleef-native/bin
    cp -v bin/* $root/sleef-native/bin
fi

if [ ! -d $root/protobuf-native ]; then
    cd $root/third_party/protobuf
    sh ./autogen.sh
    cd $root/build/native
    mkdir -p protobuf 
    cd protobuf
    export CC= CXX=
    $root/third_party/protobuf/configure --prefix=$root/protobuf-native CFLAGS="-fuse-ld=bfd" CXXFLAGS="-fuse-ld=bfd" LDFLAGS="-Wl,-fuse-ld=bfd"
    make -j$(nproc)
    make install
fi

target=x86_64-apple-darwin18
build_dir=$root/build
bits=64
blas_arch=x86_64
pkg_suffix=x86_64-darwin18

cmake_command="cmake -DCMAKE_TOOLCHAIN_FILE=$root/macos-toolchain.cmake"

export OSXCROSS_NO_INCLUDE_PATH_WARNINGS=1

cmake_args="-DNATIVE_BUILD_DIR=$root/sleef-native -DCAFFE2_CUSTOM_PROTOC_EXECUTABLE=$root/protobuf-native/bin/protoc -DWITH_BLAS=accelerate -DGLIBCXX_USE_CXX11_ABI=1 -DUSE_MKLDNN=OFF -DUSE_NNPACK=OFF -DUSE_QNNPACK=OFF -DUSE_PYTHON_QNNPACK=OFF -DUSE_FBGEMM=OFF -DUSE_EIGEN_FOR_BLAS=OFF"

mkdir -p $build_dir
cd $build_dir
$cmake_command $root $cmake_args || true
$cmake_command $root $cmake_args

make -j$(nproc) torch_cpu torch torch_global_deps

for dir in . caffe2/core/nomnigraph ; do
    sed -i "s;\"/usr/local;\"$build_dir/dist;g" $dir/cmake_install.cmake
done

for dir in . caffe2 ; do
    cmake -DCMAKE_INSTALL_LOCAL_ONLY=TRUE -DCMAKE_INSTALL_PREFIX=$(pwd)/dist -P $dir/cmake_install.cmake
done

for dir in confu-deps/pthreadpool confu-deps/cpuinfo confu-deps/pytorch_qnnpack caffe2/onnx/torch_ops third_party/fmt c10 sleef caffe2/aten caffe2/core caffe2/serialize caffe2/utils caffe2/perfkernels caffe2/contrib caffe2/predictor caffe2/predictor/emulator caffe2/core/nomnigraph caffe2/db caffe2/distributed caffe2/ideep caffe2/image caffe2/video caffe2/mobile caffe2/mpi caffe2/observers caffe2/onnx caffe2/opt caffe2/proto caffe2/python caffe2/queue caffe2/sgd caffe2/share caffe2/transforms ; do
    cmake -DCMAKE_INSTALL_PREFIX=$(pwd)/dist -P $dir/cmake_install.cmake
done

for comp in libprotobuf protobuf-headers protobuf-protos protobuf-export ; do
    cmake -DCMAKE_INSTALL_COMPONENT=$comp -DCMAKE_INSTALL_PREFIX=$(pwd)/dist -P third_party/protobuf/cmake/cmake_install.cmake
done

tar -czvf libtorch-$pkg_suffix.tar.gz --transform 's/^dist/libtorch/' dist/
