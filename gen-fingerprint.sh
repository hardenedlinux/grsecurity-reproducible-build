#! /bin/bash
export TZ=UTC
echo "KERNEL_TIMESTAMP=\"$(LC_ALL=C date)\"" > fingerprint.sh
echo "GRSEC_RANDSTRUCT_SEED=\"`od -A n -t x8 -N 32 /dev/urandom | tr -d ' \n'`\"" >> fingerprint.sh
