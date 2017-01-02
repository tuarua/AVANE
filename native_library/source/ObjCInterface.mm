#include "ObjCInterface.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include <string>
#include <boost/lexical_cast.hpp>
//#include <Adobe AIR/Adobe AIR.h>
#include "ANEhelper.h"

FREObject ObjCInterface::getCaptureDevices() {
    FREObject vecDevices = NULL;
    FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.CaptureDevice>", 0, NULL, &vecDevices, NULL);
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSArray *audioDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    
    int index = 0;
    //uint32_t num_screens = 0;
    for (AVCaptureDevice *device in videoDevices) {
        
        FREObject objDevice;
        FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.CaptureDevice", 0, NULL, &objDevice, NULL);
        FRESetObjectProperty(objDevice, (const uint8_t*)"format", getFREObjectFromString("avfoundation"), NULL);
        FRESetObjectProperty(objDevice, (const uint8_t*)"isVideo", getFREObjectFromBool(true), NULL);
        FRESetObjectProperty(objDevice, (const uint8_t*)"index", getFREObjectFromInt32(index), NULL);
        
        const char *name = [[device localizedName] UTF8String];
        index = (int)[audioDevices indexOfObject:device];
        
        FRESetObjectProperty(objDevice, (const uint8_t*)"name", getFREObjectFromString(name), NULL);
		
		
		FREObject vecCapabilities = NULL;
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.CaptureDeviceCapabilities>", 0, NULL, &vecCapabilities, NULL);
		
		NSObject *range = nil;
		NSObject *format = nil;
		int cindex = 0;
		for (format in [device valueForKey:@"formats"]) {
			CMFormatDescriptionRef formatDescription;
			CMVideoDimensions dimensions;
			formatDescription = (__bridge CMFormatDescriptionRef) [format performSelector:@selector(formatDescription)];
			dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
			
			for (range in [format valueForKey:@"videoSupportedFrameRateRanges"]) {
				
				FREObject objCapability;
				FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.CaptureDeviceCapabilities", 0, NULL, &objCapability, NULL);
				
				double min_framerate;
				double max_framerate;
				
				[[range valueForKey:@"minFrameRate"] getValue:&min_framerate];
				[[range valueForKey:@"maxFrameRate"] getValue:&max_framerate];
				
				FRESetObjectProperty(objCapability, (const uint8_t*)"width", getFREObjectFromInt32(dimensions.width), NULL);
				FRESetObjectProperty(objCapability, (const uint8_t*)"height", getFREObjectFromInt32(dimensions.height), NULL);
				FRESetObjectProperty(objCapability, (const uint8_t*)"minFrameRate", getFREObjectFromDouble(min_framerate), NULL);
				FRESetObjectProperty(objCapability, (const uint8_t*)"maxFrameRate", getFREObjectFromDouble(max_framerate), NULL);
				FRESetArrayElementAt(vecCapabilities, cindex, objCapability);
				cindex++;
				
			}
		}
		
		FRESetObjectProperty(objDevice, (const uint8_t*)"capabilities", vecCapabilities, NULL);
		
        FRESetArrayElementAt(vecDevices, getFREObjectArrayLength(vecDevices), objDevice);
        index++;
    }
	
#if !TARGET_OS_IPHONE && __MAC_OS_X_VERSION_MIN_REQUIRED >= 1070
    CGGetActiveDisplayList(0, NULL, &num_screens);
    if (num_screens > 0) {
        CGDirectDisplayID screens[num_screens];
        CGGetActiveDisplayList(num_screens, screens, &num_screens);
        for (int i = 0; i < num_screens; i++) {
            
            FREObject objDevice;
            FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.CaptureDevice", 0, NULL, &objDevice, NULL);
            FRESetObjectProperty(objDevice, (const uint8_t*)"format", getFREObjectFromString("avfoundation"), NULL);
            FRESetObjectProperty(objDevice, (const uint8_t*)"isVideo", getFREObjectFromBool(true), NULL);
            FRESetObjectProperty(objDevice, (const uint8_t*)"index", getFREObjectFromInt32(index + i), NULL);
            FRESetObjectProperty(objDevice, (const uint8_t*)"name", getFREObjectFromString("Capture screen " + boost::lexical_cast<std::string>(i)), NULL);
            FRESetArrayElementAt(vecDevices, getFREObjectArrayLength(vecDevices), objDevice);
            
        }
    }
    
#endif
	
    index = 0;
    for (AVCaptureDevice *device in audioDevices) {
        
        FREObject objDevice;
        FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.CaptureDevice", 0, NULL, &objDevice, NULL);
        FRESetObjectProperty(objDevice, (const uint8_t*)"format", getFREObjectFromString("avfoundation"), NULL);
        FRESetObjectProperty(objDevice, (const uint8_t*)"isAudio", getFREObjectFromBool(true), NULL);
        
        const char *name = [[device localizedName] UTF8String];
        index = (int)[audioDevices indexOfObject:device];
        
        FRESetObjectProperty(objDevice, (const uint8_t*)"index", getFREObjectFromInt32(index), NULL);
        FRESetObjectProperty(objDevice, (const uint8_t*)"name", getFREObjectFromString(name), NULL);
        FRESetArrayElementAt(vecDevices, getFREObjectArrayLength(vecDevices), objDevice);

        index++;
    }
    return vecDevices;
    
}
