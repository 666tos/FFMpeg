#!/bin/sh

source common.sh

FOLDER="FFmpeg-maccatalyst"

SCRATCH="$FOLDER/scratch"
# must be an absolute path
THIN=`pwd`/"$FOLDER/thin"

ARCHS="x86_64"

DEPLOYMENT_TARGET="10.15"

function Build() {
	CWD=`pwd`
	for ARCH in $ARCHS
	do
		echo "building $ARCH..."
		mkdir -p "$SCRATCH/$ARCH"
		cd "$SCRATCH/$ARCH"

		local xcode_path=$(xcode-select -p)

		CFLAGS="-arch $ARCH"
		PLATFORM="MacOSX"

		XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
		CC="xcrun -sdk $XCRUN_SDK clang"

		# force "configure" to use "gas-preprocessor.pl" (FFmpeg 3.3)
		AS="gas-preprocessor.pl -- $CC"

		CXXFLAGS="$CFLAGS"
		LDFLAGS="$CFLAGS"
		if [ "$X264" ]
		then
			CFLAGS="$CFLAGS -I$X264/include"
			LDFLAGS="$LDFLAGS -L$X264/lib"
		fi
		if [ "$FDK_AAC" ]
		then
			CFLAGS="$CFLAGS -I$FDK_AAC/include"
			LDFLAGS="$LDFLAGS -L$FDK_AAC/lib"
		fi

		CFLAGS="$CFLAGS -target x86_64-apple-ios13.0-macabi \
				-isysroot $xcode_path/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
				-isystem $xcode_path/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/iOSSupport/usr/include \
				-iframework $xcode_path/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/iOSSupport/System/Library/Frameworks"

		LDFLAGS="$LDFLAGS -target x86_64-apple-ios13.0-macabi \
				-isysroot $xcode_path/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
				-L$xcode_path/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/iOSSupport/usr/lib \
				-L$xcode_path/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/maccatalyst \
				-iframework $xcode_path/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/iOSSupport/System/Library/Frameworks"		

		TMPDIR=${TMPDIR/%\/} $CWD/$SOURCE/configure \
			--target-os=darwin \
			--arch=$ARCH \
			--cc="$CC" \
			--as="$AS" \
			$CONFIGURE_FLAGS \
			--extra-cflags="$CFLAGS" \
			--extra-ldflags="$LDFLAGS" \
			--prefix="$THIN/$ARCH" \
		|| exit 1

		make -j3 install $EXPORT || exit 1
		cd $CWD
	done
}

function CopyHeaders() {
	archs_array=($ARCHS)
	cp -rf $THIN/${archs_array[0]}/include $FOLDER
}

Prepare
Build
CopyHeaders

echo Done

