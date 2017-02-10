#include <string>
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
class ObjCInterface
{
public:
    FREObject getCaptureDevices();
};
