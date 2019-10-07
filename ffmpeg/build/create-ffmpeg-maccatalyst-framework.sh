#!/bin/sh

CURRENT_FOLDER=`pwd`

ARCHS="x86_64"
FFMPEG_VERSION="4.1"
export FFMPEG_VERSION
HEADER_SUFFIX=".h"
FRAMEWORK_NAME="FFmpeg"

FRAMEWORK_EXT=".framework"
FRAMEWORK="$FRAMEWORK_NAME$FRAMEWORK_EXT"
BUILD_FOLDER="$CURRENT_FOLDER/FFmpeg-maccatalyst"
SCRATCH="$BUILD_FOLDER/scratch"

BUILD_INCLUDE_FOLDER="$BUILD_FOLDER/include"
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

mkdir -p "$BUILD_FOLDER/tmp"

function LibTool() {
	local object_files=$1
	local xcode_path=$(xcode-select -p)

	echo "$object_files"

	libtool -static -arch_only $ARCHS -D \
		 -syslibroot $xcode_path/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk \
		 -L$xcode_path/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk/System/iOSSupport/usr/lib \
		 -L$xcode_path/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/uikitformac \
		 $object_files \
		 -o $FRAMEWORK_NAME

	mv $FRAMEWORK_NAME $OUTPUT_FOLDER
}

#MergeStaticLibrary
#LibTool

function CreateInfoPlist() {
	default_macos_sdk_version=`defaults read $(xcode-select -p)/Platforms/MacOSX.platform/version CFBundleShortVersionString`

	read -r -d '' extra_entries << EOF
			<key>UIDeviceFamily</key>
			<array>
				<integer>2</integer>
			</array>
EOF

	WriteInfoPlist "MacOSX" "macosx" $default_macos_sdk_version "10.15" "$extra_entries"
}

CreateFramework

FindObjectFiles
LibTool $OBJECT_FILES

#RenameHeader
#CreateModulemapAndUmbrellaHeader
#CopyInttype
#CreateInfoPlist
