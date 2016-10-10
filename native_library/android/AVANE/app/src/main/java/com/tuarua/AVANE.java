package com.tuarua;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

/**
 * Created by Eoin Landy on 09/10/2016.
 */

public class AVANE implements FREExtension {
    @Override
    public void initialize() {

    }

    @Override
    public FREContext createContext(String s) {
        AVANEContext context = new AVANEContext();
        return context;
    }

    @Override
    public void dispose() {

    }
}
