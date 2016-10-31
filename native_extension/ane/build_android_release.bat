@echo off
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"

SET projectName=AVANE

copy %pathtome%..\bin\%projectName%.swc %pathtome%

REM contents of SWC.
copy /Y %pathtome%%projectName%.swc %pathtome%%projectName%Extract.swc
ren %pathtome%%projectName%Extract.swc %projectName%Extract.zip
call %SZIP% e %pathtome%%projectName%Extract.zip -o%pathtome%
del %pathtome%%projectName%Extract.zip

REM Copy library.swf to folders.
echo COPYING LIBRARY SWF INTO PLACE
copy %pathtome%library.swf %pathtome%platforms\android

echo COPYING AARS INTO PLACE
copy /Y %pathtome%..\..\native_library\android\%projectName%\app\build\outputs\aar\app-release.aar %pathtome%platforms\android\app-release.aar
copy /Y %pathtome%..\..\native_library\android\%projectName%\LibAVANE-Android\build\outputs\aar\LibAVANE-Android-release.aar %pathtome%platforms\android\LibAVANE-Android-release.aar


echo GETTING ANDROID JARS
call %SZIP% x %pathtome%platforms\android\LibAVANE-Android-release.aar -o%pathtome%platforms\android\ classes.jar
ren %pathtome%platforms\android\classes.jar LibAVANE.jar
del platforms\\android\\classes.jar

call %SZIP% x %pathtome%platforms\android\LibAVANE-Android-release.aar -o%pathtome%platforms\android\ jni\armeabi-v7a\libavane-lib.so
call %SZIP% x %pathtome%platforms\android\LibAVANE-Android-release.aar -o%pathtome%platforms\android\ jni\armeabi-v7a\libffmpeg.so
call %SZIP% x %pathtome%platforms\android\LibAVANE-Android-release.aar -o%pathtome%platforms\android\ jni\armeabi\libavane-lib.so
call %SZIP% x %pathtome%platforms\android\LibAVANE-Android-release.aar -o%pathtome%platforms\android\ jni\armeabi\libffmpeg.so
call %SZIP% x %pathtome%platforms\android\LibAVANE-Android-release.aar -o%pathtome%platforms\android\ jni\x86\libavane-lib.so
call %SZIP% x %pathtome%platforms\android\LibAVANE-Android-release.aar -o%pathtome%platforms\android\ jni\x86\libffmpeg.so

move %pathtome%platforms\android\jni %pathtome%platforms\android\libs

call %SZIP% x %pathtome%platforms\android\app-release.aar -o%pathtome%platforms\android\ classes.jar

echo "GENERATING ANE"
call adt.bat -package -target ane %projectName%-android.ane extension_android.xml ^
-swc %projectName%.swc ^
-platform Android-ARM ^
-C platforms/android library.swf classes.jar ^
libs/armeabi/libavane-lib.so ^
libs/armeabi/libffmpeg.so ^
libs/armeabi-v7a/libavane-lib.so ^
libs/armeabi-v7a/libffmpeg.so ^
-platformoptions platforms/android/platform.xml res/values/strings.xml ^
LibAVANE.jar ^
-platform Android-x86 ^
-C platforms/android library.swf classes.jar ^
libs/x86/libavane-lib.so ^
libs/x86/libffmpeg.so ^
-platformoptions platforms/android/platform.xml res/values/strings.xml ^
LibAVANE.jar ^


del platforms\\android\\library.swf
del platforms\\android\\classes.jar
del platforms\\android\\LibAVANE.jar
del platforms\\android\\app-release.aar
del platforms\\android\\LibAVANE-Android-release.aar
call DEL /F /Q /A %pathtome%library.swf
call DEL /F /Q /A %pathtome%catalog.xml
call DEL /F /Q /A %pathtome%%projectName%.swc
call rmdir /Q /S %pathtome%platforms\android\libs

echo "DONE!"