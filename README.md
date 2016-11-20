# AVANE

Adobe Air Native Extension written in ActionScript 3 and C/C++ for encoding + decoding video and audio based on FFMpeg libraries.
Samples included

Universal player - demo showing flash playing mp4, mkv, webm encoded in h264, hevc and vp9. Also showcases live HLS streams from Twitch and Vevo.  
N.B. Depending on your computer setup HEVC decoding may be very slow. So a 6 year old mac mini is not going to cut it :)

Advanced client - demo similar to Handbrake 

Desktop capture - demo using screen-capture-recorder to capture desktop (Windows only)


![alt tag](https://raw.githubusercontent.com/tuarua/AVANE/master/screenshots/screen-shot-1.png)


### Features
 - Harness the power of FFmpeg with this unoffical ANE version.

### Tech

AVANE uses the following libraries:

* [https://github.com/ShiftMediaProject/FFmpeg] - ShiftMediaProject FFmpeg
* [http://www.boost.org] - C++ portable libraries
* [http://www.frogtoss.com/labs] - Native File Dialog
* [https://nlohmann.github.io/json] - JSON for Modern C++
* [https://github.com/rdp/screen-capture-recorder-to-video-windows-free] - required for desktop capture example


### Prerequisites

You will need
 
 - Flash Builder 4.7
 - AIR 22 SDK

### Todos
 - Full source code of ANE
 - Add ASDocs
