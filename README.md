# AVANE

##### I've hit my LFS limit for the January on Github. You may have trouble downloading the ANEs

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=D9VQZQPGPLFKW)

Adobe Air Native Extension for OSX / WIN / Android / iOS written in ActionScript 3 and C/C++ for encoding + decoding video and audio based on FFMpeg libraries.
Samples included.

Universal player - demo showing flash playing mp4, mkv, webm encoded in h264, hevc and vp9. Also showcases live HLS streams from NASA.  
N.B. Depending on your computer setup HEVC decoding may be very slow. So a 6 year old mac mini is not going to cut it :)

Advanced client - demo similar to Handbrake 

Desktop capture - demo using screen-capture-recorder to capture desktop (Windows only)

Camera recording - demo using camera to record video (iOS only)


![alt tag](https://raw.githubusercontent.com/tuarua/AVANE/master/screenshots/screen-shot-1.png)

### AS Docs 
[https://tuarua.github.io/AVANE/native_extension/docs/asdocs/] 



### Features
 - Harness the power of FFmpeg with this unoffical ANE version.

### Tech

AVANE uses the following libraries:

* [https://github.com/ShiftMediaProject/FFmpeg] - ShiftMediaProject FFmpeg
* [http://www.boost.org] - C++ portable libraries
* [http://www.frogtoss.com/labs] - Native File Dialog
* [https://nlohmann.github.io/json] - JSON for Modern C++
* [http://jsoncpp.sourceforge.net/] - Json-cpp
* [https://github.com/rdp/screen-capture-recorder-to-video-windows-free] - required for desktop capture example


### Prerequisites

You will need
 
 - Flash Builder 4.7 / IntelliJ
 - AIR 24 SDK

### Todos
 - Full source code of ANE
