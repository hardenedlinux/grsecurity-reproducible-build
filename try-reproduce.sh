#! /bin/bash -e

NO_ENTER_FIXED_DIR=1
. fixed-dir.sh
. ver.sh
unset NO_ENTER_FIXED_DIR

rm -rf out out0 $FIXED_DIRECTORY/linux-$LINUX_VER{,-old} deb deb0
./build-kernel.sh && mv $FIXED_DIRECTORY/linux-$LINUX_VER{,-old} && mv out out0 && ./build-kernel.sh
mkdir deb deb0
mv out/*.deb deb/
mv out0/*.deb deb0/
diff -r out{0,}
for i in deb/*.deb
do
	./deb-diff.sh "$i" deb0/"$(basename "$i")"
done
