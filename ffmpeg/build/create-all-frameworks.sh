#!/bin/sh

./create-ffmpeg-ios-framework.sh
./create-ffmpeg-maccatalyst-framework.sh
./create-ffmpeg-osx-framework.sh
./create-ffmpeg-tvos-framework.sh

./create-ffmpeg-xcframework.sh