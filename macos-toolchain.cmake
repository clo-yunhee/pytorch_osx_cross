# OSXCross toolchain

set(OSXCROSS_HOST x86_64-apple-darwin18)
set(OSXCROSS_TARGET_DIR $ENV{HOME}/Builds/osxcross/target)
set(OSXCROSS_SDK ${OSXCROSS_TARGET_DIR}/SDK/MacOSX10.14.sdk)

set(CMAKE_SYSTEM_NAME "Darwin")
set(CMAKE_SYSTEM_VERSION "18.2.0")
string(REGEX REPLACE "-.*" "" CMAKE_SYSTEM_PROCESSOR "${OSXCROSS_HOST}")

# specify the cross compiler
set(CMAKE_C_COMPILER "${OSXCROSS_TARGET_DIR}/bin/${OSXCROSS_HOST}-gcc")
set(CMAKE_CXX_COMPILER "${OSXCROSS_TARGET_DIR}/bin/${OSXCROSS_HOST}-g++")

# where is the target environment
set(CMAKE_FIND_ROOT_PATH
  "${OSXCROSS_SDK}"
  "${OSXCROSS_TARGET_DIR}/${OSXCROSS_HOST}/qt5")

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_AR "${OSXCROSS_TARGET_DIR}/bin/${OSXCROSS_HOST}-ar" CACHE FILEPATH "ar")
set(CMAKE_RANLIB "${OSXCROSS_TARGET_DIR}/bin/${OSXCROSS_HOST}-ranlib" CACHE FILEPATH "ranlib")
set(CMAKE_INSTALL_NAME_TOOL "${OSXCROSS_TARGET_DIR}/bin/${OSXCROSS_HOST}-install_name_tool" CACHE FILEPATH "install_name_tool")

set(CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG "-Wl,-rpath,")
set(CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG_SEP ":")
set(CMAKE_INSTALL_NAME_DIR "@rpath")
set(CMAKE_INSTALL_RPATH ...)

set(PKG_CONFIG_EXECUTABLE "${OSXCROSS_TARGET_DIR}/bin/${OSXCROSS_HOST}-pkg-config")
set(ENV{OSXCROSS_PKG_CONFIG_SYSROOT_DIR} "")
set(ENV{OSXCROSS_PKG_CONFIG_LIBDIR} "${OSXCROSS_TARGET_DIR}/${OSXCROSS_HOST}/lib/pkgconfig:${OSXCROSS_TARGET_DIR}/${OSXCROSS_HOST}/share/pkgconfig")
