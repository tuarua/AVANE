//
//  Utils.hpp
//  AVANE
//
//  Created by User on 25/04/2016.
//  Copyright © 2016 Tua Rua Ltd. All rights reserved.
//

#ifndef Utils_hpp
#define Utils_hpp

#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
#include <windows.h>
#include <conio.h>

#elif __APPLE__

#include "TargetConditionals.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
// iOS Simulator
#include "FlashRuntimeExtensions.h"

#elif TARGET_OS_MAC
// Other kinds of Mac OS
#include <Adobe AIR/Adobe AIR.h>

#else
#   error "Unknown Apple platform"
#endif

#endif

extern "C" {
#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
FRE_FUNCTION(getColors);
FRE_FUNCTION(getLayouts);
FRE_FUNCTION(getProtocols);
FRE_FUNCTION(getFilters);
FRE_FUNCTION(getPixelFormats);
FRE_FUNCTION(getBitStreamFilters);
FRE_FUNCTION(getDecoders);
FRE_FUNCTION(getEncoders);
FRE_FUNCTION(getCodecs);
FRE_FUNCTION(getHardwareAccelerations);
FRE_FUNCTION(getDevices);
FRE_FUNCTION(getAvailableFormats);
FRE_FUNCTION(getBuildConfiguration);
FRE_FUNCTION(getLicense);
FRE_FUNCTION(getVersion);
FRE_FUNCTION(getSampleFormats);
}
#endif /* Utils_hpp */
