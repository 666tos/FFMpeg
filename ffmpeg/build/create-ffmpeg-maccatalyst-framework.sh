#!/bin/sh

CURRENT_FOLDER=`pwd`

ARCHS="x86_64"
FFMPEG_VERSION="4.1"
export FFMPEG_VERSION
HEADER_SUFFIX=".h"
FRAMEWORK_NAME="FFmpeg"

FRAMEWORK_EXT=".framework"
LIB_EXT=".a"
FRAMEWORK="$FRAMEWORK_NAME$FRAMEWORK_EXT"
LIBRARY="$FRAMEWORK_NAME$LIB_EXT"
BUILD_FOLDER="$CURRENT_FOLDER/FFmpeg-maccatalyst"
SCRATCH="$BUILD_FOLDER/scratch"

BUILD_INCLUDE_FOLDER="$BUILD_FOLDER/include"
TMP_FOLDER="$BUILD_FOLDER/tmp"
BUILD_LIB_FOLDER="$BUILD_FOLDER/lib"
OUTPUT_FOLDER="$BUILD_FOLDER/$FRAMEWORK"
OUTPUT_INFO_PLIST_FILE="$OUTPUT_FOLDER/Info.plist"
OUTPUT_HEADER_FOLDER="$OUTPUT_FOLDER/Headers"
OUTPUT_UMBRELLA_HEADER="$OUTPUT_HEADER_FOLDER/ffmpeg.h"
OUTPUT_MODULES_FOLDER="$OUTPUT_FOLDER/Modules"
OUTPUT_MODULES_FILE="$OUTPUT_MODULES_FOLDER/module.modulemap"
VERSION_NEW_NAME="Version.h"
BUNDLE_ID="org.ffmpeg.FFmpeg"

source framework_utils.sh

function LibTool() {
	local object_files=$1
	local xcode_path=$(xcode-select -p)

	echo "$object_files"

	export MACOSX_DEPLOYMENT_TARGET=10.15

	libtool \
		-static -arch_only $ARCHS -D \
		-syslibroot $xcode_path/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk \
		-L$xcode_path/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk/System/iOSSupport/usr/lib \
		-L$xcode_path/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/maccatalyst \
		$object_files \
		-o "$TMP_FOLDER/$LIBRARY"
}

CreateTmpFolder
FindAllObjectFiles
LibTool "$OBJECT_FILES"
