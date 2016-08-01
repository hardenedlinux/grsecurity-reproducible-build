#! /bin/bash
export TZ=UTC
# The timestamp of kernel building, used for the embedded initramfs, /proc/version and kernel build
echo "KERNEL_TIMESTAMP=\"$(LC_ALL=C date)\"" > fingerprint.sh
# The seed used for Grsecurity's RANDSTRUCT plugin.
echo "GRSEC_RANDSTRUCT_SEED=\"`od -A n -t x8 -N 32 /dev/urandom | tr -d ' \n'`\"" >> fingerprint.sh
