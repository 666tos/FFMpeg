#!/bin/sh

CURRENT_FOLDER=`pwd`

ARCHS="x86_64"
FFMPEG_VERSION="4.1"
export FFMPEG_VERSION
HEADER_SUFFIX=".h"
FRAMEWORK_NAME="FFmpeg"

FRAMEWORK_EXT=".framework"
FRAMEWORK="$FRAMEWORK_NAME$FRAMEWORK_EXT"
BUILD_FOLDER="$CURRENT_FOLDER/FFmpeg-OSX"
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

function CreateInfoPlist() {
	default_macos_sdk_version=`defaults read $(xcode-select -p)/Platforms/MacOSX.platform/version CFBundleShortVersionString`

	WriteInfoPlist "MacOSX" "macosx" $default_macos_sdk_version "10.10"
}

CreateFramework
MergeStaticLibraryIntoFramework
RenameHeader
CreateModulemapAndUmbrellaHeader
CopyInttype
CreateInfoPlist
