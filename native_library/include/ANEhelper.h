/*@copyright The code is licensed under the[MIT
License](http://opensource.org/licenses/MIT):

Copyright 2015 - 2017 Tua Rua Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files(the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions :

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/
#pragma once
#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
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

#include <vector>
#include <string>

class ANEHelper {
public:
	static FREObject getFREObject(std::string arg);

	static FREObject getFREObject(const char *arg);

	static FREObject getFREObject(double arg);

	static FREObject getFREObject(bool arg);

	static FREObject getFREObject(int32_t arg);

	static FREObject getFREObject(int64_t arg);

	static FREObject getFREObject(uint32_t arg);

	static FREObject getFREObject(uint8_t arg);

	static FREObject getProperty(FREObject objAS, std::string propertyName);

	static void setProperty(FREObject objAS, std::string name, FREObject value);

	static void setProperty(FREObject objAS, std::string name, const char *value);

	static void setProperty(FREObject objAS, std::string name, std::string value);

	static void setProperty(FREObject objAS, std::string name, double value);

	static void setProperty(FREObject objAS, std::string name, bool value);

	static void setProperty(FREObject objAS, std::string name, int32_t value);

	static void setProperty(FREObject objAS, std::string name, int64_t value);

	static void setProperty(FREObject objAS, std::string name, uint32_t value);

	static void setProperty(FREObject objAS, std::string name, uint8_t value);

	static uint32_t getUInt32(FREObject uintAS);

	static int32_t getInt32(FREObject intAS);

	static std::string getString(FREObject arg);

	static bool getBool(FREObject val);

	static double getDouble(FREObject arg);

	static uint32_t getArrayLength(FREObject arrayAS);

	static std::vector<std::string> getStringVector(FREObject arg, std::string propertyName);

	static FREObject createFREObject(std::string className);

	static void dispatchEvent(FREContext ctx, std::string name, std::string value);

};
