#!/bin/sh

#  RUNME.sh
#  AVANE
#
#  Created by User on 31/10/2016.
#  Copyright © 2016 Tua Rua Ltd. All rights reserved.

CURR_DIR=`pwd`
INCLUDE_DIR=$CURR_DIR/../../../include/ios

git clone https://github.com/danoli3/ofxiOSBoost.git
mkdir "$INCLUDE_DIR/boost"
mkdir "$INCLUDE_DIR/boost/include"
mv "ofxiOSBoost/libs/boost/include/boost" "$INCLUDE_DIR/boost/include/boost"
mv "ofxiOSBoost/libs/boost/ios/libboost.a" "$CURR_DIR"

rm -rf ofxiOSBoost

wget https://github.com/tuarua/FFmpeg-for-iOS-Prebuilt/releases/download/v3.2/ffmpeg-x264-ios-fat.zip
unzip ffmpeg-x264-ios-fat.zip
rm ffmpeg-x264-ios-fat.zip

mv ffmpeg-x264-ios-fat/libavcodec.a libavcodec.a
mv ffmpeg-x264-ios-fat/libavdevice.a libavdevice.a
mv ffmpeg-x264-ios-fat/libavfilter.a libavfilter.a
mv ffmpeg-x264-ios-fat/libavformat.a libavformat.a
mv ffmpeg-x264-ios-fat/libavutil.a libavutil.a
mv ffmpeg-x264-ios-fat/libpostproc.a libpostproc.a
mv ffmpeg-x264-ios-fat/libswresample.a libswresample.a
mv ffmpeg-x264-ios-fat/libswscale.a libswscale.a
mv ffmpeg-x264-ios-fat/libx264.a libx264.a

rm -r ffmpeg-x264-ios-fat
