# CLI tools for XZ and LZMA compression
# https://tukaani.org/xz/
#
#!BUILDTOOL toolchain
#!BUILDTOOL ports/curl if HERMETIC
#
#!DEP ports/libc
#
source /p/tools/pbuild.lib.sh

# Note: when upgrading, don't forget to also update lib/pbuild.sh
VERSION=5.6.2
pbuild_fetch_and_unpack \
    https://tukaani.org/xz/xz-$VERSION.tar.xz \
    a9db3bb3d64e248a0fae963f8fb6ba851a26ba1822e504dc0efd18a80c626caf

pbuild_apply_patches

rm -rf $DESTDIR/xz-void
mkdir $DESTDIR/xz-void

pbuild_configure_once ./configure \
    --host=$CHOST \
    --prefix=/usr \
    --datadir=/usr/share \
    --bindir=/bin \
    --libdir=/lib \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-shared \
    --enable-static \
    --enable-threads=yes \
    --disable-rpath \
    --disable-werror \
    --disable-doc \
    --disable-nls \
    --enable-sandbox=landlock \
    \
    --disable-lzmadec \
    --disable-lzmainfo \
    --disable-lzma-links \
    \
    --libdir=/xz-void \
    --includedir=/xz-void

make -j$MAXJOBS
if [ $ARCH = $NATIVE_ARCH ]; then
    make -j$MAXJOBS check
fi
make -j$MAXJOBS DESTDIR=$DESTDIR install

rm -rf $DESTDIR/xz-void

# strip
# Note: We can't use 'make install-strip' since there's some error in the makefiles that attempts
# to strip static libraries:
#   strip: error: '/distroot/xz-void/liblzma.a(liblzma_la-tuklib_physmem.o)':
#   The file was not recognized as a valid object file
for exe in xz xzdec; do
    echo strip "$DESTDIR/bin/$exe"
    strip "$DESTDIR/bin/$exe"
done
