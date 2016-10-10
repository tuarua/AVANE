package com.tuarua.utils;

import com.adobe.fre.FREASErrorException;
import com.adobe.fre.FREArray;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FRENoSuchNameException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREReadOnlyException;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

/**
 * Created by Eoin Landy on 24/07/2016.
 */
public class ANEhelper {
    private static ANEhelper ourInstance = new ANEhelper();

    public static ANEhelper getInstance() {
        return ourInstance;
    }

    private ANEhelper() {
    }
    public FREObject getFREObjectFromBool(Boolean value) {
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject getFREObjectFromString(String value){
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }
    public FREObject getFREObjectFromInt(int value) {
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }
    public FREObject getFREObjectFromLong(long value) {
        FREObject result = null;

        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject getFREObjectFromDouble(double value) {
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject getFREObjectFromFloat(float value) {
        FREObject result = null;
        try {
            result = FREObject.newObject(value);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject getFREObjectProperty(FREObject freObj, String propertyName){
        FREObject result = null;
        try {
            result = freObj.getProperty(propertyName);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public int getIntFromFREObject(FREObject freObj){
        int result = 0;
        try {
            result = freObj.getAsInt();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public String getStringFromFREObject(FREObject freObj) {
        String result = ""; //or null ?
        if(freObj != null){
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

    public Boolean getBoolFromFREObject(FREObject freObj) {
        Boolean result = false;
        try {
            result = freObj.getAsBool();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public long getFREObjectArrayLength(FREArray freObj) {
        long result = 0;
        try {
            result = freObj.getLength();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject createFREObject(String name, FREObject freObjects[]){
        FREObject result = null;
        try {
            result = FREObject.newObject(name,freObjects);
        } catch (FRETypeMismatchException | FREWrongThreadException | FRENoSuchNameException | FREASErrorException | FREInvalidObjectException e) {
            e.printStackTrace();
        }
        return result;
    }

    public FREObject setFREObjectProperty(FREObject freObject, String name, FREObject prop){
        try {
            freObject.setProperty(name,prop);
        } catch (FRETypeMismatchException | FRENoSuchNameException | FREWrongThreadException | FREReadOnlyException | FREASErrorException | FREInvalidObjectException e) {
            e.printStackTrace();
        }
        return freObject;
    }

    public FREObject getReturnTrue() {
        return getFREObjectFromBool(true);
    }



}