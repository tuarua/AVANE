
REM Get the path to the script and trim to get the directory.
@echo off
SET pathtome=%~dp0
echo cleaning %pathtome%
DEL /F /S /Q /A %pathtome%AVANE.swc
DEL /F /S /Q /A %pathtome%library.swf
DEL /F /S /Q /A %pathtome%catalog.xml
rd /S /Q %pathtome%platforms\win

