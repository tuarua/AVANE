/*@copyright The code is licensed under the[MIT
License](http://opensource.org/licenses/MIT):

Copyright © 2015 - 2017 Tua Rua Ltd.

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
package com.tuarua.utils;

import com.adobe.fre.FREASErrorException;
import com.adobe.fre.FREArray;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FRENoSuchNameException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREReadOnlyException;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class ANEhelper {
    private static ANEhelper ourInstance = new ANEhelper();

    public static ANEhelper getInstance() {
        return ourInstance;
    }

    private ANEhelper() {
    }

    public FREObject getFREObject(Boolean value) {
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject getFREObject(String value) {
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject getFREObject(int value) {
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject getFREObject(long value) {
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject getFREObject(double value) {
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject getFREObject(float value) {
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }


    public FREObject getProperty(FREObject freObj, String propertyName) {
        FREObject result = null;
        try {
            result = freObj.getProperty(propertyName);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public int getInt(FREObject freObj) {
        int result = 0;
        try {
            result = freObj.getAsInt();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public String getString(FREObject freObj) {
        String result = ""; //or null ?
        if (freObj != null) {
            try {
                result = freObj.getAsString();
                return result;
            } catch (Exception e) {
                e.printStackTrace();
                e.getCause();
            }
        }
        return result;
    }

    public Boolean getBool(FREObject freObj) {
        Boolean result = false;
        try {
            result = freObj.getAsBool();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public long getArrayLength(FREArray freObj) {
        long result = 0;
        try {
            result = freObj.getLength();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject createFREObject(String name, FREObject freObjects[]) {
        FREObject result = null;
        try {
            result = FREObject.newObject(name, freObjects);
        } catch (FRETypeMismatchException | FREWrongThreadException | FRENoSuchNameException | FREASErrorException | FREInvalidObjectException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject setProperty(FREObject freObject, String name, FREObject prop) {
        try {
            freObject.setProperty(name, prop);
        } catch (FRETypeMismatchException | FRENoSuchNameException | FREWrongThreadException | FREReadOnlyException | FREASErrorException | FREInvalidObjectException e) {
            e.printStackTrace();
        }
        return freObject;
    }

    public FREObject setProperty(FREObject freObject, String name, String value) {
        return setProperty(freObject, name, value);
    }

    public FREObject setProperty(FREObject freObject, String name, Boolean value) {
        return setProperty(freObject, name, value);
    }

    public FREObject setProperty(FREObject freObject, String name, int value) {
        return setProperty(freObject, name, value);
    }

    public FREObject setProperty(FREObject freObject, String name, long value) {
        return setProperty(freObject, name, value);
    }

    public FREObject setProperty(FREObject freObject, String name, double value) {
        return setProperty(freObject, name, value);
    }

    public FREObject setProperty(FREObject freObject, String name, float value) {
        return setProperty(freObject, name, value);
    }
}