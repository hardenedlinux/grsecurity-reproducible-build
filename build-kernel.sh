#! /bin/bash -e

DEBEMAIL="voldemort@ministry_of_magic"
DEBFULLNAME="Who Must Not Be Named"

KDEB_CHANGELOG_DIST="Debian"

if [ -e config ]; then
	CONFIG="$PWD/config"
else
	CONFIG=
fi

SCRIPTDIR="$PWD"

OUTDIR="$PWD/out"
mkdir -p "$OUTDIR"
cp fingerprint.sh "$OUTDIR"/

. ver.sh

. arch.sh

. concur.sh

. fingerprint.sh

. fixed-dir.sh

TOOLS_PREFIX="$FIXED_DIRECTORY/tools"

LINUX_SRC="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${LINUX_VER}.tar.xz"
LINUX_SIGN="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${LINUX_VER}.tar.sign"
LINUX_SIGN_FILE="linux-${LINUX_VER}.tar.sign"
LINUX_TBL_CMP="linux-${LINUX_VER}.tar.xz"
LINUX_TBL_DECMP="unxz"
LINUX_TBL="linux-${LINUX_VER}.tar"
LINUX_DIR="linux-${LINUX_VER}"

GRSEC_FILE="grsecurity-${GRSEC_VER}.patch"

if [ ! -e "$LINUX_TBL" ]; then
	wget "$LINUX_SRC" -O "$LINUX_TBL_CMP"
	wget "$LINUX_SIGN" -O "$LINUX_SIGN_FILE"
	"$LINUX_TBL_DECMP" "$LINUX_TBL_CMP"
	gpg --verify "$LINUX_SIGN_FILE" "$LINUX_TBL"
fi

if [ ! -e "$GRSEC_FILE" ]; then
	cp "$SCRIPTDIR/$GRSEC_FILE" .
fi

# Ensure the build is clean
rm -rf "$LINUX_DIR"
rm -f *.deb

tar xvf "$LINUX_TBL"

cd "$LINUX_DIR"

patch -Np1 -i ../"$GRSEC_FILE"

export KBUILD_BUILD_TIMESTAMP="${KERNEL_TIMESTAMP}"
export KBUILD_BUILD_USER=grsec
export KBUILD_BUILD_HOST=grsec
export KCONFIG_NOTIMESTAMP=1
export XZ_OPT="--check=crc64"
export ROOT_DEV=FLOPPY

chmod 755 scripts/gcc-plugin.sh # Without this command, the script cannot be executed under Debian.

sed "s/@SEED@/$GRSEC_RANDSTRUCT_SEED/g" < "$SCRIPTDIR"/hacks/gen-random-seed.sh.in > scripts/gcc-plugins/gen-random-seed.sh

sed -i 's/$(date -R)/$(date -R --date="'"$KERNEL_TIMESTAMP"'")/g' scripts/package/builddeb
sed -i 's/gzip/gzip -n/g' scripts/package/builddeb

if [ "$CONFIG" ]; then
	cp $CONFIG .config
else
	make ARCH="$LINUX_ARCH" CROSS_COMPILE="$TOOLS_PREFIX"/bin/"$TOOLS_TRIPLET"- defconfig
fi
make ARCH="$LINUX_ARCH" CROSS_COMPILE="$TOOLS_PREFIX"/bin/"$TOOLS_TRIPLET"- "$KERNEL_CONCUR" bindeb-pkg

cp ../*.deb "$OUTDIR"/
cp arch/x86/boot/bzImage vmlinux "$OUTDIR"/
make ARCH="$LINUX_ARCH" CROSS_COMPILE="$TOOLS_PREFIX"/bin/"$TOOLS_TRIPLET"- INSTALL_MOD_PATH="$OUTDIR" modules_install
