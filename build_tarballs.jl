# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "ZLibBuilder"
version = v"0.1.0"

# Collection of sources required to build ZLibBuilder
sources = [
    "https://zlib.net/zlib-1.2.11.tar.gz" =>
    "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/zlib-1.2.11/

if [[ ${target} == *-w64-mingw* ]]; then
    EXTRA_CONFIGURE_FLAGS="--sharedlibdir=${prefix}/bin"
    EXTRA_MAKE_FLAGS="SHAREDLIB=libz.dll SHAREDLIBM=libz-1.dll SHAREDLIBV=libz-1.2.11.dll LDSHAREDLIBC= "
fi

./configure ${EXTRA_CONFIGURE_FLAGS} --prefix=$prefix

make install ${EXTRA_MAKE_FLAGS} -j${nproc}

if [[ ${target} == *-w64-mingw* ]]; then
    mkdir ${WORKSPACE}/destdir/tmp
    cp -L ${WORKSPACE}/destdir/bin/* ${WORKSPACE}/destdir/tmp
    rm -r ${WORKSPACE}/destdir/bin
    mv ${WORKSPACE}/destdir/tmp ${WORKSPACE}/destdir/bin
fi

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    FreeBSD(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libz", :libz)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

