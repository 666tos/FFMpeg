#!/bin/sh

function CreateFramework() {
	rm -rf $OUTPUT_FOLDER
	mkdir -p $OUTPUT_HEADER_FOLDER $OUTPUT_MODULES_FOLDER
}

function CreateTmpFolder() {
	rm -rf $TMP_FOLDER
	mkdir $TMP_FOLDER
}

function FindAllObjectFiles() {
	local files=""

	cd "$BUILD_FOLDER"

	OBJECT_FILES=""

	for ARCH in $ARCHS; do
		folder="$SCRATCH/$ARCH"

		name=$(find $folder  -maxdepth 3 -name "*.o")
		OBJECT_FILES="$OBJECT_FILES $name"
	done
}

function FindObjectFiles() {
	local arch=$1

	cd "$BUILD_FOLDER"

	OBJECT_FILES=""

	folder="$SCRATCH/$arch"

	name=$(find $folder -maxdepth 3 -name "*.o")
	OBJECT_FILES="$OBJECT_FILES $name"

#	echo "RESULT:"
#	echo $OBJECT_FILES
}

function MergeStaticLibraryIntoFramework() {
	local files=""

	cd "$BUILD_FOLDER"
	rm -rf tmp
	mkdir tmp
	cd tmp

	for ARCH in $ARCHS; do
		folder="$SCRATCH/$ARCH"
		name="$FRAMEWORK_NAME$ARCH.a"
		ar cru $name $(find $folder -name "*.o")
		files="$files $name"
	done

	lipo -create $files -output FFmpeg

	mv $FRAMEWORK_NAME $OUTPUT_FOLDER
}

function RenameHeader() {
	local include_folder="$BUILD_INCLUDE_FOLDER"
	local need_replace_version_folder=""

	for folder in "$include_folder"/*; do
		local folder_name=`basename $folder`
		local verstion_file_name="$folder_name$VERSION_NEW_NAME"
		for header in "$folder"/*; do
				local header_name=`basename $header`

				local dst_name=$header_name
				if [ $header_name == "version.h" ]; then
					dst_name=$verstion_file_name
				fi

				local dst_folder=$OUTPUT_HEADER_FOLDER
				local file_name="$folder/$header_name"
				local dst_file_name="$dst_folder/$dst_name"
				cp $file_name $dst_file_name
				find "$dst_folder" -name "$dst_name" -type f -exec sed -i '' "s/\"version.h\"/\"$verstion_file_name\"/g" {} \;
			done
		need_replace_version_folder="$need_replace_version_folder $folder_name"
	done

	for folder_name in $need_replace_version_folder; do
		local verstion_file_name="$folder_name$VERSION_NEW_NAME"
		find $OUTPUT_HEADER_FOLDER -type f -exec sed -i '' "s/\"$folder_name\/version.h\"/\"$verstion_file_name\"/g" {} \;
	done

	find $OUTPUT_HEADER_FOLDER -type f -exec sed -i '' "s/libavformat\///g" {} \;
	find $OUTPUT_HEADER_FOLDER -type f -exec sed -i '' "s/libavutil\///g" {} \;
	find $OUTPUT_HEADER_FOLDER -type f -exec sed -i '' "s/libavcodec\///g" {} \;
}

function CreateModulemapAndUmbrellaHeader() {
	#create ffmpeg.h
	cat > $OUTPUT_UMBRELLA_HEADER <<EOF
#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AudioToolbox/AudioToolbox.h>
#include "avcodec.h"
#include "avdevice.h"
#include "avfilter.h"
#include "avformat.h"
#include "avutil.h"
#include "swscale.h"
#include "swresample.h"
double FFmpegVersionNumber = $FFMPEG_VERSION;
EOF

	cat > $OUTPUT_MODULES_FILE <<EOF
framework module $FRAMEWORK_NAME {
  umbrella header "ffmpeg.h"

  export *
  module * { export * }
}
EOF
}

# COPY MISSING inttypes.h
function CopyInttype() {
  local file="$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/clang/include/inttypes.h"
	cp $file $OUTPUT_HEADER_FOLDER
	find $OUTPUT_HEADER_FOLDER -type f -exec sed -i '' "s/<inttypes.h>/\"inttypes.h\"/g" {} \;
}

function WriteInfoPlist() {
	supported_platform=$1
	platform_name=$2
	platform_version=$3
	min_os_version=$4
	extra_entries=$5

	DTCompiler=`defaults read $(xcode-select -p)/../info DTCompiler`
	DTPlatformBuild=`defaults read $(xcode-select -p)/../info DTPlatformBuild`
	DTSDKBuild=`defaults read $(xcode-select -p)/../info DTSDKBuild`
	DTXcode=`defaults read $(xcode-select -p)/../info DTXcode`
	DTXcodeBuild=`defaults read "$(xcode-select -p)/../info" DTXcodeBuild`
	OS_BUILD_VERSION=$(sw_vers -buildVersion)

	cat > $OUTPUT_INFO_PLIST_FILE <<EOF
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
		  <key>BuildMachineOSBuild</key>
		  <string>$OS_BUILD_VERSION</string>
		  <key>CFBundleDevelopmentRegion</key>
		  <string>en</string>
		  <key>CFBundleExecutable</key>
		  <string>$FRAMEWORK_NAME</string>
		  <key>CFBundleIdentifier</key>
		  <string>$BUNDLE_ID</string>
		  <key>CFBundleInfoDictionaryVersion</key>
		  <string>6.0</string>
		  <key>CFBundleName</key>
		  <string>$FRAMEWORK_NAME</string>
		  <key>CFBundlePackageType</key>
		  <string>FMWK</string>
		  <key>CFBundleShortVersionString</key>
		  <string>$FFMPEG_VERSION</string>
		  <key>CFBundleSignature</key>
		  <string>????</string>
		  <key>CFBundleSupportedPlatforms</key>
		  <array>
		  <string>$supported_platform</string>
		  </array>
		  <key>CFBundleVersion</key>
		  <string>1</string>
		  <key>DTCompiler</key>
		  <string>$DTCompiler</string>
		  <key>DTPlatformBuild</key>
		  <string>$DTPlatformBuild</string>
		  <key>DTPlatformName</key>
		  <string>$platform_name</string>
		  <key>DTPlatformVersion</key>
		  <string>$platform_version</string>
		  <key>DTSDKBuild</key>
		  <string>$DTSDKBuild</string>
		  <key>DTSDKName</key>
		  <string>$platform_name$platform_version</string>
		  <key>DTXcode</key>
		  <string>$DTXcode</string>
		  <key>DTXcodeBuild</key>
		  <string>$DTXcodeBuild</string>
		  <key>MinimumOSVersion</key>
		  <string>$min_os_version</string>
		  $extra_entries
	</dict>
	</plist>
EOF
}