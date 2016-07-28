#! /bin/bash -e
DEB1="$(readlink -f $1)"
DEB2="$(readlink -f $2)"

tempdir="$(mktemp -d)"

cd "$tempdir"
dpkg -x "$DEB1" d1
dpkg -x "$DEB2" d2
dpkg -e "$DEB1" d1/DEBIAN
dpkg -e "$DEB2" d2/DEBIAN

diff -r --no-dereference d1 d2

cd /tmp
rm -rf "$tempdir"
