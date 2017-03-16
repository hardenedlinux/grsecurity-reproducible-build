# The theory of the reproducible build

## Fixed environment

### Fixed C Compiler

The C compiler usually acts differently for different version. So to deterministically build a kernel, a fixed C compiler version is needed.

In order to provided the fixed-version C compiler independently (have no effect from the host's C compiler and libc), a "cross-compiler" is built here. (To build the cross-compiler, a different triplet, "x86_64-kernelonly-linux-gnu" is used)

As the cross-compiler is used only to build the kernel, the cross libc and stage2 GCC is not built, only a stage1 GCC is built. This is barely enough for kernel building.

Note: To run the built kernel, the cross-compiler is *NOT* needed.

### Fixed directory

In order to build the kernel deterministically, a fixed build directory is requied.

Currently the build script used "/kbuild" as the fixed directory.

## Fixed build info

### Build fingerprint

The volatile build info used in the scripts is written to a file named "fingerprint.sh".

It contains two variables:

- KERNEL_TIMESTAMP: A timestamp used in kernel building process

- GRSEC_RANDSTRUCT_SEED: the random seed of struct randomize.

### Machine info

The kernel will contain some info (hostname, username) retrieved from the build machine.

But, fortunately, they can be overwritten with environment variables: KBUILD_BUILD_USER and KBUILD_BUILD_HOST.

### Kill the timestamps

Kernel building needs a timestamp. It can be passed to the kernel build system with the environment variable "KBUILD_BUILD_TIMESTAMP".

Debian packaging needs also a timestamp (for the debian changelog). In order to remove it, the "builddeb" script in the kernel source is patched.

Gzip contains also some timestamps. The compression in the kernel has already no timestamps, as a patch have been merged into the kernel source for deterministic build. The compression in the "builddeb" script is also patched, to pass the "-n" option to Gzip, which disabled the internal timestamp of Gzip.

## Simple building process

```
           +--------------+
           | Enter run.sh |
           +--------------+
                   |
                   |
                  \*/
     +----------------------------+  Specified a .deb file
     | Checkout for the arguments |-------------------------+
     +----------------------------+                         |
                   |                                        |
                   | Have no .deb file parameter            |
                  \*/                                       |
+-----------------------------------------+                 |
| Check or generate the build fingerprint |                 |
+-----------------------------------------+                 |
                   |                                        |
                   |                     +------------------------------------+
                   |                     | Extract the fingerprint and config |
                   |                     +------------------------------------+
                   |                                        |
                   |    +-----------------------------------+
                   |    |
                   |    |                                               run.sh
-------------------+----+------------------------------------------------------
                   |    |
                  \*/  \*/
      +----------------------------------+
      | Download the source of toolchain |
      +----------------------------------+
                       |
                       |
                      \*/
              +----------------+
              | Build binutils | The version of Binutils is specified.
              +----------------+
                       |
                       |
                      \*/
    +--------------------------------------+
    | Bundle supplement libraries into GCC |
    +--------------------------------------+
                       |
                       |
                      \*/
                 +-----------+
                 | Build GCC | The version of GCC is specified.
                 +-----------+
                       |
                       |
                      \*/
   +----------------------------------------+
   | Copy GCC supplement libraries' headers |
   +----------------------------------------+
                       |
                       |                                    build-toolchain.sh
-----------------------+-------------------------------------------------------
                       |                                       build-kernel.sh
                      \*/
     +------------------------------------+
     | Set a fixed fake build environemnt |
     +------------------------------------+
                       |
                       |
                      \*/
       +------------------------------+
       | Download linux kernel source |
       +------------------------------+
                       |
                       |
                      \*/
        +----------------------------+
        | Apply PaX/Grsecurity patch |
        +----------------------------+
                       |
                       |
                      \*/
        +-----------------------------+
        | Copy the kernel config file |
        +-----------------------------+
                       |
                       |
                      \*/
+-----------------------------------------------+
| Use the kernel build system to build and pack | Packing process is patched.
+-----------------------------------------------+
                       |
		       |
		       |                        +------------------+
		       |<-----------------------| signing vmlinuz* |
                       |                        +------------------+
                      \*/
          +------------------------+
          | Copy the files to out/ |
          +------------------------+
```
