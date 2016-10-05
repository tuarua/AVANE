package com.tuarua.avane.android;

import android.util.Log;

/**
 * Created by User on 04/10/2016.
 */

public class JniHandler {
    private JniHandler(){

    }
    public void dispatchStatusEventAsync(String msg,String type) {
        Log.i("message",msg);
        Log.i("type",type);
    }
}
