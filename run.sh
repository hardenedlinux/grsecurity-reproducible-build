#! /bin/bash -e

export TZ=UTC

if [ "$1" = "--help" ]; then
	echo \
"Usage: $0" "
" "      $0 linux-image-foo.deb" "
" "      $0 fingerprint-file config-file"
	exit 0
fi

echo "NOTE: the old config and fingerprint.sh MAY BE OVERRIDEN!"
echo "PLEASE BACK THEM UP BEFORE USING THIS SCRIPT!"

if [ "$1" != "" ]; then
	if file "$1" | grep -q "Debian binary package"; then
		if ! basename "$1" | grep -q "^linux-image"; then
			echo
			echo "ERROR: The debian package filename is not prefixed linux-image-"
			echo "We doubt that it's not a linux image package."
			echo "Abort now"
			exit 1
		fi
		# It's a deb, we will try to extract it
		tmpdir="$(mktemp -d)"
		dpkg-deb -x "$1" "$tmpdir"
		if [ -e "$tmpdir"/boot/fingerprint* ]; then
			rm -f fingerprint.sh
			cp "$tmpdir"/boot/fingerprint* fingerprint.sh
		else
			echo
			echo "This package do not contain a build fingerprint."
			if [ -e fingerprint.sh ]; then
				echo "The current one will be used."
			else
				echo "A new fingerprint will be generated."
				./gen-fingerprint.sh
			fi
		fi
		if [ -e "$tmpdir"/boot/config* ]; then
			rm -f config
			cp "$tmpdir"/boot/config* config
		else
			echo
			echo "This package do not contain a kernel config."
			echo "Cannot continue."
			exit 1
		fi
	else
		cp "$1" fingerprint.sh
	fi
elif [ "$1" = "fingerprint.sh" ]; then
	# Do nothing
	:
else
	if [ ! -e fingerprint.sh ]; then
		echo "Generating new build fingerprint..."
		./gen-fingerprint.sh
	fi
fi

if [ "$2" = "config" ]; then
	# Do nothing
	:
elif [ "$2" != "" ]; then
	cp "$2" config
else
	if [ ! -e config ]; then
		echo "No config file specified!"
		echo "Please specify a config file."
		echo "Recommended config file:"
		echo "$PWD/configs/paxed-mint-config is a configuration file derived from Linux Mint's configuration, which is suitablefor using on Debian-derived distributions."
		exit 1
fi

if [ ! -e concur.sh ]; then
	echo
	echo "concur.sh does not exist."
	echo "It will be generated with \"nproc\" conmand."
	echo "export TOOLCHAIN_CONCUR=-j$(nproc)" > concur.sh
	echo "KERNEL_CONCUR=-j$(nproc)" >> concur.sh
fi

./build-toolchain.sh && ./build-kernel.sh
