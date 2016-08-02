#! /bin/bash -e

export TZ=UTC

SCRIPTDIR="$PWD"

OUTDIR="$PWD/out"
mkdir -p "$OUTDIR"

. ver.sh

. arch.sh

. concur.sh

. fingerprint.sh

. fixed-dir.sh

TOOLS_PREFIX="$FIXED_DIRECTORY/tools"

LINUX_DIR="linux-${LINUX_VER}"

cd $LINUX_DIR

# Some variables for deterministic kernel build
export KBUILD_BUILD_TIMESTAMP="${KERNEL_TIMESTAMP}"
export SOURCE_DATE_EPOCH="$DEB_BUILD_TIMESTAMP"
export KBUILD_BUILD_USER=grsec
export KBUILD_BUILD_HOST=grsec
export KCONFIG_NOTIMESTAMP=1
export XZ_OPT="--check=crc64"
export ROOT_DEV=FLOPPY

# build extra kernel modules

if [ -d "$SCRIPTDIR"/modules ]; then
	cp -r "$SCRIPTDIR"/modules .

	cd modules
	for i in *
	do
		if [ ! -d "$i" ]; then	
			continue
		fi

		pushd $i
			make ARCH="$LINUX_ARCH" CROSS_COMPILE="$TOOLS_PREFIX"/bin/"$TOOLS_TRIPLET"- M="$PWD" -C "$PWD/../.." modules
			mkdir -p "$OUTDIR"/modules
			cp *.ko "$OUTDIR"/modules
		popd
	done
fi
