#!/bin/sh

SOURCE="../"
FOLDER="FFmpeg-tvOS"

SCRATCH="$FOLDER/scratch"
# must be an absolute path
THIN=`pwd`/"$FOLDER/thin"


# absolute path to x264 library
#X264=`pwd`/../x264-ios/x264-iOS

#FDK_AAC=`pwd`/fdk-aac/fdk-aac-ios

CONFIGURE_FLAGS="--enable-cross-compile \
				 --disable-debug --disable-programs --disable-doc \
				 --disable-encoders --disable-decoders --disable-protocols --disable-filters  \
				 --disable-muxers --disable-bsfs --disable-indevs --disable-outdevs --disable-demuxers \
				 --enable-pic \
				 --enable-decoder=h264 \
				 --enable-demuxer=mpegts \
				 --enable-parser=h264 \
				 --enable-videotoolbox"

if [ "$X264" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-gpl --enable-libx264"
fi

if [ "$FDK_AAC" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libfdk-aac --enable-nonfree"
fi

# avresample
#CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-avresample"

ARCHS="arm64 x86_64"

DEPLOYMENT_TARGET="10.2"

function Prepare() {
	if [ ! `which yasm` ]
	then
		echo 'Yasm not found'
		if [ ! `which brew` ]
		then
			echo 'Homebrew not found. Trying to install...'
						ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
				|| exit 1
		fi
		echo 'Trying to install Yasm...'
		brew install yasm || exit 1
	fi
	if [ ! `which gas-preprocessor.pl` ]
	then
		echo 'gas-preprocessor.pl not found. Trying to install...'
		(curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
			-o /usr/local/bin/gas-preprocessor.pl \
			&& chmod +x /usr/local/bin/gas-preprocessor.pl) \
			|| exit 1
	fi

	if [ ! -r $SOURCE ]
	then
		echo 'FFmpeg source not found. Trying to download...'
		curl http://www.ffmpeg.org/releases/$SOURCE.tar.bz2 | tar xj \
			|| exit 1
	fi
}

function Build() {
	CWD=`pwd`
	for ARCH in $ARCHS
	do
		echo "building $ARCH..."
		mkdir -p "$SCRATCH/$ARCH"
		cd "$SCRATCH/$ARCH"

		CFLAGS="-arch $ARCH"
		if [ "$ARCH" = "x86_64" ]
		then
			PLATFORM="AppleTVSimulator"
			CFLAGS="$CFLAGS -mtvos-simulator-version-min=$DEPLOYMENT_TARGET"
		else
			PLATFORM="AppleTVOS"
			CFLAGS="$CFLAGS -mtvos-version-min=$DEPLOYMENT_TARGET -fembed-bitcode"
			if [ "$ARCH" = "arm64" ]
			then
				EXPORT="GASPP_FIX_XCODE5=1"
			fi
		fi

		XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
		CC="xcrun -sdk $XCRUN_SDK clang"
		AR="xcrun -sdk $XCRUN_SDK ar"
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

		TMPDIR=${TMPDIR/%\/} $CWD/$SOURCE/configure \
			--target-os=darwin \
			--arch=$ARCH \
			--cc="$CC" \
			--ar="$AR" \
			$CONFIGURE_FLAGS \
			--extra-cflags="$CFLAGS" \
			--extra-ldflags="$LDFLAGS" \
			--prefix="$THIN/$ARCH" \
		|| exit 1

		xcrun -sdk $XCRUN_SDK make -j3 install $EXPORT || exit 1
		cd $CWD
	done
}

function CopyHeaders() {
	cp -rf $THIN/${ARCHS[0]}/include $FOLDER
}

Prepare
Build
CopyHeaders

echo Done
