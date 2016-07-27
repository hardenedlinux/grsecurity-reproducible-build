# Grsecurity Reproducible build scripts

These scripts are intended to do reproducible build for Linux kernel with Grsecurity patch set.

## Usage

```
./build-toolchain.sh # Build a intermediate toolchain
./gen-fingerprint.sh # Or copy other build fingerprint to fingerprint.sh
./build-kernel.sh # Build the kernel itself
```

Then the output kernel (bzImage, vmlinux, modules, and build fingerprint) is located at out/
