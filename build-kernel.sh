#! /bin/bash -e

if [ -e config ]; then
	CONFIG="$PWD/config"
else
	CONFIG=
fi

OUTDIR="$PWD/out"
mkdir -p "$OUTDIR"

. ver.sh

. arch.sh

. concur.sh

. fixed-dir.sh

KERNEL_TIMESTAMP="Mon Jul 25 14:41:53 SGT 2016"

TOOLS_PREFIX="$FIXED_DIRECTORY/tools"

LINUX_SRC="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${LINUX_VER}.tar.xz"
LINUX_SIGN="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${LINUX_VER}.tar.sign"
LINUX_SIGN_FILE="linux-${LINUX_VER}.tar.sign"
LINUX_TBL_CMP="linux-${LINUX_VER}.tar.xz"
LINUX_TBL_DECMP="unxz"
LINUX_TBL="linux-${LINUX_VER}.tar"
LINUX_DIR="linux-${LINUX_VER}"

GRSEC_SRC="https://grsecurity.net/test/grsecurity-${GRSEC_VER}.patch"
GRSEC_FILE="grsecurity-${GRSEC_VER}.patch"

if [ ! -e "$LINUX_TBL" ]; then
	wget "$LINUX_SRC" -O "$LINUX_TBL_CMP"
	wget "$LINUX_SIGN" -O "$LINUX_SIGN_FILE"
	"$LINUX_TBL_DECMP" "$LINUX_TBL_CMP"
	gpg --verify "$LINUX_SIGN_FILE" "$LINUX_TBL"
fi

if [ ! -e "$GRSEC_FILE" ]; then
	wget "$GRSEC_SRC" -O "$GRSEC_FILE"
fi

# Ensure the build is clean
rm -rf "$LINUX_DIR"

tar xvf "$LINUX_TBL"

cd "$LINUX_DIR"

patch -Np1 -i ../"$GRSEC_FILE"

export KBUILD_BUILD_TIMESTAMP="${KERNEL_TIMESTAMP}"
export KBUILD_BUILD_USER=grsec
export KBUILD_BUILD_HOST=grsec
export KCONFIG_NOTIMESTAMP=1
export XZ_OPT="--check=crc64"
export ROOT_DEV=FLOPPY

if [ "$CONFIG" ]; then
	cp $CONFIG .config
else
	make ARCH="$LINUX_ARCH" CROSS_COMPILE="$TOOLS_PREFIX"/bin/"$TOOLS_TRIPLET"- defconfig
fi
make ARCH="$LINUX_ARCH" CROSS_COMPILE="$TOOLS_PREFIX"/bin/"$TOOLS_TRIPLET"- "$KERNEL_CONCUR"

cp arch/x86/boot/bzImage vmlinux "$OUTDIR"/
make ARCH="$LINUX_ARCH" CROSS_COMPILE="$TOOLS_PREFIX"/bin/"$TOOLS_TRIPLET"- INSTALL_MOD_PATH="$OUTDIR" modules_install
