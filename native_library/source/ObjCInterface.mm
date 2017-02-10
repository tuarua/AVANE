#include "ObjCInterface.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include <string>
#include <boost/lexical_cast.hpp>
#ifdef _WIN32
#elif __APPLE__
#include "TargetConditionals.h"
#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)
#include "FlashRuntimeExtensions.h"
#elif TARGET_OS_MAC
#include <Adobe AIR/Adobe AIR.h>

#else
#   error "Unknown Apple platform"
#endif

#endif

#include <ANEhelper.h>

ANEHelper aneHelper3 = ANEHelper();

FREObject ObjCInterface::getCaptureDevices() {
    FREObject vecDevices = aneHelper3.createFREObject("Vector.<com.tuarua.ffmpeg.gets.CaptureDevice>");
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSArray *audioDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    
    int index = 0;
    uint32_t num_screens = 0;
    for (AVCaptureDevice *device in videoDevices) {
        
        FREObject objDevice = aneHelper3.createFREObject("com.tuarua.ffmpeg.gets.CaptureDevice");

        aneHelper3.setProperty(objDevice, "format", "avfoundation");
        aneHelper3.setProperty(objDevice, "isVideo", true);
        aneHelper3.setProperty(objDevice, "index", index);
        
        const char *name = [[device localizedName] UTF8String];
        index = (int)[audioDevices indexOfObject:device];

        aneHelper3.setProperty(objDevice, "name", name);

		FREObject vecCapabilities = aneHelper3.createFREObject("Vector.<com.tuarua.ffmpeg.gets.CaptureDeviceCapabilities>");
		
		NSObject *range = nil;
		NSObject *format = nil;
		uint32_t cindex = 0;
		for (format in [device valueForKey:@"formats"]) {
			CMFormatDescriptionRef formatDescription;
			CMVideoDimensions dimensions;
			formatDescription = (__bridge CMFormatDescriptionRef) [format performSelector:@selector(formatDescription)];
			dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
			
			for (range in [format valueForKey:@"videoSupportedFrameRateRanges"]) {
				
				FREObject objCapability = aneHelper3.createFREObject("com.tuarua.ffmpeg.gets.CaptureDeviceCapabilities");
				
				double min_framerate;
				double max_framerate;
				
				[[range valueForKey:@"minFrameRate"] getValue:&min_framerate];
				[[range valueForKey:@"maxFrameRate"] getValue:&max_framerate];

                aneHelper3.setProperty(objCapability, "width", dimensions.width);
                aneHelper3.setProperty(objCapability, "height", dimensions.height);
                aneHelper3.setProperty(objCapability, "minFrameRate", min_framerate);
                aneHelper3.setProperty(objCapability, "maxFrameRate", max_framerate);

				FRESetArrayElementAt(vecCapabilities, cindex, objCapability);
				cindex++;
				
			}
		}

        aneHelper3.setProperty(objDevice, "capabilities", vecCapabilities);
		
        FRESetArrayElementAt(vecDevices, aneHelper3.getArrayLength(vecDevices), objDevice);
        index++;
    }
	
#if !TARGET_OS_IPHONE && __MAC_OS_X_VERSION_MIN_REQUIRED >= 1070
    CGGetActiveDisplayList(0, NULL, &num_screens);
    if (num_screens > 0) {
        CGDirectDisplayID screens[num_screens];
        CGGetActiveDisplayList(num_screens, screens, &num_screens);
        for (int i = 0; i < num_screens; i++) {
            
            FREObject objDevice = aneHelper3.createFREObject("com.tuarua.ffmpeg.gets.CaptureDevice");
            aneHelper3.setProperty(objDevice, "format", "avfoundation");
            aneHelper3.setProperty(objDevice, "isVideo", true);
            aneHelper3.setProperty(objDevice, "index", index + i);
            aneHelper3.setProperty(objDevice, "name", "Capture screen " + boost::lexical_cast<std::string>(i));

            FRESetArrayElementAt(vecDevices, aneHelper3.getArrayLength(vecDevices), objDevice);
            
        }
    }
    
#endif

    for (AVCaptureDevice *device in audioDevices) {

        FREObject objDevice = aneHelper3.createFREObject("com.tuarua.ffmpeg.gets.CaptureDevice");

        aneHelper3.setProperty(objDevice, "format", "avfoundation");
        aneHelper3.setProperty(objDevice, "isAudio", true);
        
        const char *name = [[device localizedName] UTF8String];
        index = (int)[audioDevices indexOfObject:device];

        aneHelper3.setProperty(objDevice, "index", index);
        aneHelper3.setProperty(objDevice, "name", name);

        FRESetArrayElementAt(vecDevices, aneHelper3.getArrayLength(vecDevices), objDevice);

    }
    return vecDevices;
    
}
