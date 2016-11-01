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

#include <boost/lexical_cast.hpp>

FREObject getColors(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getLayouts(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getProtocols(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getFilters(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getPixelFormats(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getBitStreamFilters(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getDecoders(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getEncoders(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getCodecs(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getHardwareAccelerations(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getDevices(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getAvailableFormats(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getBuildConfiguration(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getLicense(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getVersion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getSampleFormats(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
#endif /* Utils_hpp */
