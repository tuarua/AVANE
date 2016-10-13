#!/bin/sh

#Get the path to the script and trim to get the directory.
echo "Setting path to current directory to:"
pathtome=$0
pathtome="${pathtome%/*}"
echo $pathtome

PROJECT_NAME=AVANE

AIR_SDK="/Applications/Adobe Flash Builder 4.7/sdks/4.6.0"
echo $AIR_SDK

#Setup the directory.
echo "Making directories."

#Copy SWC into place.
echo "Copying SWC into place."
cp "$pathtome/../bin/$PROJECT_NAME.swc" "$pathtome/"

#Extract contents of SWC.
echo "Extracting files form SWC."
unzip "$pathtome/$PROJECT_NAME.swc" "library.swf" -d "$pathtome"

#Copy library.swf to folders.
echo "Copying library.swf into place."
cp "$pathtome/library.swf" "$pathtome/platforms/android"


echo "COPYING AARS INTO PLACE"
cp "$pathtome/../../native_library/android/$PROJECT_NAME/app/build/outputs/aar/app-release.aar" "$pathtome/platforms/android/app-release.aar"
cp "$pathtome/../../native_library/android/$PROJECT_NAME/LibAVANE-Android/build/outputs/aar/LibAVANE-Android-release.aar" "$pathtome/platforms/android/LibAVANE-Android-release.aar"

echo GETTING ANDROID JARS
unzip "$pathtome/platforms/android/LibAVANE-Android-release.aar" "classes.jar" -d "$pathtome/platforms/android"

mv "$pathtome/platforms/android/classes.jar" "$pathtome/platforms/android/LibAVANE.jar"
rm "$pathtome/platforms/android/classes.jar"

unzip "$pathtome/platforms/android/LibAVANE-Android-release.aar" "jni/armeabi-v7a/libavane-lib.so" -d "$pathtome/platforms/android"
unzip "$pathtome/platforms/android/LibAVANE-Android-release.aar" "jni/armeabi-v7a/libffmpeg.so" -d "$pathtome/platforms/android"
unzip "$pathtome/platforms/android/LibAVANE-Android-release.aar" "jni/armeabi/libavane-lib.so" -d "$pathtome/platforms/android"
unzip "$pathtome/platforms/android/LibAVANE-Android-release.aar" "jni/armeabi/libffmpeg.so" -d "$pathtome/platforms/android"
unzip "$pathtome/platforms/android/LibAVANE-Android-release.aar" "jni/x86/libavane-lib.so" -d "$pathtome/platforms/android"
unzip "$pathtome/platforms/android/LibAVANE-Android-release.aar" "jni/x86/libffmpeg.so" -d "$pathtome/platforms/android"


mv "$pathtome/platforms/android/jni" "$pathtome/platforms/android/libs"
unzip "$pathtome/platforms/android/app-release.aar" "classes.jar" -d "$pathtome/platforms/android"


#Run the build command.
echo "GENERATING ANE"

"$AIR_SDK/bin/adt" -package -target ane "$PROJECT_NAME-android.ane" "$pathtome/extension_android.xml" \
-swc "$pathtome/$PROJECT_NAME.swc" \
-platform Android-ARM \
-C "$pathtome/platforms/android" "library.swf" "classes.jar" \
"libs/armeabi/libavane-lib.so" \
"libs/armeabi/libffmpeg.so" \
"libs/armeabi-v7a/libavane-lib.so" \
"libs/armeabi-v7a/libffmpeg.so" \
-platformoptions "platforms/android/platform.xml" "res/values/strings.xml" \
"LibAVANE.jar" \
-platform Android-x86 \
-C "$pathtome/platforms/android" "library.swf" "classes.jar" \
"libs/x86/libavane-lib.so" \
"libs/x86/libffmpeg.so" \
-platformoptions "platforms/android/platform.xml" "res/values/strings.xml" \
"LibAVANE.jar"


rm "$pathtome/platforms/android/library.swf"
rm "$pathtome/platforms/android/classes.jar"
rm "$pathtome/platforms/android/LibAVANE.jar"
rm "$pathtome/platforms/android/app-release.aar"
rm "$pathtome/platforms/android/LibAVANE-Android-release.aar"
rm "$pathtome/library.swf"
rm "$pathtome/catalog.xml"
rm "$pathtome/$PROJECT_NAME.swc"
rm -r "$pathtome/platforms/android/libs"
