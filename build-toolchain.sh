#! /bin/bash -e

. ver.sh

. arch.sh

. concur.sh

. fixed-dir.sh

TOOLS_PREFIX="$FIXED_DIRECTORY/tools"

BINUTILS_SRC="ftp://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.bz2"
BINUTILS_TBL="binutils-${BINUTILS_VER}.tar.bz2"
BINUTILS_SIG_EXT=".sig"
BINUTILS_DIR="binutils-${BINUTILS_VER}"

if [ ! -e "$BINUTILS_TBL" ]; then
	wget "$BINUTILS_SRC" -O "$BINUTILS_TBL"
	wget "$BINUTILS_SRC$BINUTILS_SIG_EXT" -O "$BINUTILS_TBL$BINUTILS_SIG_EXT"
	if [ "$VERIFY_GPG" != "0" ]; then
		gpg --verify "$BINUTILS_TBL$BINUTILS_SIG_EXT" "$BINUTILS_TBL"
	else
		true
	fi
fi

GCC_SRC="ftp://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.bz2"
GCC_TBL="gcc-${GCC_VER}.tar.bz2"
GCC_SIG_EXT=".sig"
GCC_DIR="gcc-${GCC_VER}"

if [ ! -e "$GCC_TBL" ]; then
	wget "$GCC_SRC" -O "$GCC_TBL"
	wget "$GCC_SRC$GCC_SIG_EXT" -O "$GCC_TBL$GCC_SIG_EXT"
	if [ "$VERIFY_GPG" != "0" ]; then
		gpg --verify "$GCC_TBL$GCC_SIG_EXT" "$GCC_TBL"
	else
		true
	fi
fi

GMP_SRC="ftp://ftp.gnu.org/gnu/gmp/gmp-${GMP_VER}.tar.xz"
GMP_TBL="gmp-${GMP_VER}.tar.xz"
GMP_SIG_EXT=".sig"
GMP_DIR="gmp-${GMP_VER}"

if [ ! -e "$GMP_TBL" ]; then
	wget "$GMP_SRC" -O "$GMP_TBL"
	wget "$GMP_SRC$GMP_SIG_EXT" -O "$GMP_TBL$GMP_SIG_EXT"
	if [ "$VERIFY_GPG" != "0" ]; then
		gpg --verify "$GMP_TBL$GMP_SIG_EXT" "$GMP_TBL"
	else
		true
	fi
fi

MPFR_SRC="ftp://ftp.gnu.org/gnu/mpfr/mpfr-${MPFR_VER}.tar.xz"
MPFR_TBL="mpfr-${MPFR_VER}.tar.xz"
MPFR_SIG_EXT=".sig"
MPFR_DIR="mpfr-${MPFR_VER}"

if [ ! -e "$MPFR_TBL" ]; then
	wget "$MPFR_SRC" -O "$MPFR_TBL"
	wget "$MPFR_SRC$MPFR_SIG_EXT" -O "$MPFR_TBL$MPFR_SIG_EXT"
	if [ "$VERIFY_GPG" != "0" ]; then
		gpg --verify "$MPFR_TBL$MPFR_SIG_EXT" "$MPFR_TBL"
	else
		true
	fi
fi

MPC_SRC="ftp://ftp.gnu.org/gnu/mpc/mpc-${MPC_VER}.tar.gz"
MPC_TBL="mpc-${MPC_VER}.tar.gz"
MPC_SIG_EXT=".sig"
MPC_DIR="mpc-${MPC_VER}"

if [ ! -e "$MPC_TBL" ]; then
	wget "$MPC_SRC" -O "$MPC_TBL"
	wget "$MPC_SRC$MPC_SIG_EXT" -O "$MPC_TBL$MPC_SIG_EXT"
	if [ "$VERIFY_GPG" != "0" ]; then
		gpg --verify "$MPC_TBL$MPC_SIG_EXT" "$MPC_TBL"
	else
		true
	fi
fi

ISL_SRC="http://isl.gforge.inria.fr/isl-${ISL_VER}.tar.xz"
ISL_TBL="isl-${ISL_VER}.tar.xz"
ISL_DIR="isl-${ISL_VER}"

if [ ! -e "$ISL_TBL" ]; then
	wget "$ISL_SRC" -O "$ISL_TBL"
fi

if [ "$BUILD_BINUTILS" != "0" ]; then

	rm -rf "$BINUTILS_DIR"

	tar xvfj "$BINUTILS_TBL"

	cd "$BINUTILS_DIR"

	mkdir -p build
	cd build

	../configure --prefix="$TOOLS_PREFIX" \
		     --target="$TOOLS_TRIPLET" \
		     --enable-gold=yes --enable-plugins \
		     --enable-threads --with-lib-path="$TOOLS_PREFIX"/lib
	make configure-host
	make "$TOOLCHAIN_CONCUR"
	make install

	cd ../..

fi

rm -rf "$GCC_DIR"

tar xvfj "$GCC_TBL"

cd "$GCC_DIR"

tar xvfJ ../"$GMP_TBL"
mv "$GMP_DIR" gmp
tar xvfJ ../"$MPFR_TBL"
mv "$MPFR_DIR" mpfr
tar xvfz ../"$MPC_TBL"
mv "$MPC_DIR" mpc
tar xvfJ ../"$ISL_TBL"
mv "$ISL_DIR" isl

mkdir -p build
cd build

AR=ar ../configure --prefix="$TOOLS_PREFIX" --target="$TOOLS_TRIPLET" \
		   --with-sysroot="$TOOLS_PREFIX" --disable-shared \
		   --without-headers \
		   --with-newlib \
		   --disable-decimal-float \
		   --disable-libgomp \
		   --disable-libatomic \
		   --disable-libitm \
		   --disable-libsanitizer \
		   --disable-libquadmath \
		   --disable-libvtv \
		   --disable-libcilkrts \
		   --disable-libstdc++-v3 \
		   --disable-threads \
		   --disable-multilib \
		   --enable-languages=c
make "$TOOLCHAIN_CONCUR" all-gcc all-target-libgcc all-target-libssp
make install-gcc install-target-libgcc install-target-libssp

cd ../..
