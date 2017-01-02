#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
extern "C" {
    __declspec(dllexport) void TRAVAExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
    __declspec(dllexport) void TRAVAExtFinizer(void* extData);
}
#elif __APPLE__
#include "TargetConditionals.h"
#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)
#include "FlashRuntimeExtensions.h"
#elif TARGET_OS_MAC
#include <Adobe AIR/Adobe AIR.h>

#define EXPORT __attribute__((visibility("default")))
extern "C" {
    EXPORT
    void TRAVAExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
    
    EXPORT
    void TRAVAExtFinizer(void* extData);
}
#else
#   error "Unknown Apple platform"
#endif

#include <stdlib.h>
#include <stdio.h>

#endif
