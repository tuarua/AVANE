#!/bin/sh

#Get the path to the script and trim to get the directory.
echo "Setting path to current directory to:"
pathtome=$0
pathtome="${pathtome%/*}"
echo $pathtome

AIR_SDK="/Applications/Adobe Flash Builder 4.7/sdks/4.6.0"
echo $AIR_SDK

#Setup the directory.
echo "Making directories."

mkdir "$pathtome/platforms"
mkdir "$pathtome/platforms/mac"
mkdir "$pathtome/platforms/mac/debug"

#Copy SWC into place.
echo "Copying SWC into place."
cp "$pathtome/../bin/AVANE.swc" "$pathtome/"

#Extract contents of SWC.
echo "Extracting files form SWC."
unzip "$pathtome/AVANE.swc" "library.swf" -d "$pathtome"

#Copy library.swf to folders.
echo "Copying library.swf into place."
cp "$pathtome/library.swf" "$pathtome/platforms/mac/debug"

#Copy native libraries into place.
echo "Copying native libraries into place."
cp -R -L "$pathtome/../../native_library/mac/AVANE/Build/Products/Debug/AVANE.framework" "$pathtome/platforms/mac/debug"

#Run the build command.

echo "Building Debug."
"$AIR_SDK"/bin/adt -package \
-target ane "$pathtome/AVANE-debug.ane" "$pathtome/extension_osx.xml" \
-swc "$pathtome/AVANE.swc" \
-platform MacOS-x86-64 -C "$pathtome/platforms/mac/debug" "AVANE.framework" "library.swf"

if [[ -d "$pathtome/debug" ]]
then
rm -r "$pathtome/debug"
fi


mkdir "$pathtome/debug"
unzip "$pathtome/AVANE-debug.ane" -d  "$pathtome/debug/AVANE.ane/"

rm -r "$pathtome/platforms"
rm "$pathtome/AVANE.swc"
rm "$pathtome/library.swf"
rm "$pathtome/AVANE-debug.ane"