#!/bin/bash
#

SCRIPTPATH=$PWD
FAT_DIR="ios/fat"
ARM64_DIR="ios/arm64"
ARMV7_DIR="ios/armv7"
X86_64_DIR="ios/x86_64"

if [ ! -d $FAT_DIR ]; then
	mkdir -p $FAT_DIR
fi

# combine lib files for various platforms into one

for filepath in $ARM64_DIR/*.a; do
	filename="${filepath##*/}"
	echo $filename

	arm64Path="$PWD/$ARM64_DIR/$filename"
	armv7Path="$PWD/$ARMV7_DIR/$filename"
	x8664Path="$PWD/$X86_64_DIR/$filename"
	fatPath="$PWD/$FAT_DIR/$filename"

	lipo -create $arm64Path $armv7Path $x8664Path -output $fatPath || die "Could not create static output library"
done

exit 0
