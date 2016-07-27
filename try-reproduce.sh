#! /bin/bash -e

NO_ENTER_FIXED_DIR=1
. fixed-dir.sh
unset NO_ENTER_FIXED_DIR

rm -rf out out0 $FIXED_DIRECTORY/linux-4.6.4{,-old}
./build-kernel.sh && mv $FIXED_DIRECTORY/linux-4.6.4{,-old} && mv out out0 && ./build-kernel.sh
diff -r out{0,}
