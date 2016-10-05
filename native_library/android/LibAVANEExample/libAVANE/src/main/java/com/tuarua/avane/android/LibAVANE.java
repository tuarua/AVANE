package com.tuarua.avane.android;

import android.util.Log;

import com.tuarua.avane.android.gets.AvailableFormat;
import com.tuarua.avane.android.gets.BitStreamFilter;
import com.tuarua.avane.android.gets.Codec;
import com.tuarua.avane.android.gets.Color;
import com.tuarua.avane.android.gets.Decoder;
import com.tuarua.avane.android.gets.Device;
import com.tuarua.avane.android.gets.Encoder;
import com.tuarua.avane.android.gets.Filter;
import com.tuarua.avane.android.gets.HardwareAcceleration;
import com.tuarua.avane.android.gets.Layout;
import com.tuarua.avane.android.gets.Layouts;
import com.tuarua.avane.android.gets.PixelFormat;
import com.tuarua.avane.android.gets.Protocol;
import com.tuarua.avane.android.gets.Protocols;
import com.tuarua.avane.android.gets.SampleFormat;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

/**
 * Created by User on 02/10/2016.
 */
public class LibAVANE {
    private static LibAVANE ourInstance = new LibAVANE();

    public static LibAVANE getInstance() {
        return ourInstance;
    }

    private LibAVANE() {
    }

    public void triggerProbeInfo(String filename, String playlist) {
        jni_triggerProbeInfo(filename, playlist);
    }

    public void getProbeInfo(String filename, String playlist) {
        jni_getProbeInfo(filename,playlist);
        //extensionContext.call("triggerProbeInfo",filename,playlist);
    }

    public ArrayList<Filter> getFilters(){
        ArrayList<Filter> vecFilters = new ArrayList<>();
        String json = jni_getFilters();
        try {
            JSONArray jsonArray = new JSONArray(json);
            JSONObject jsonObject;
            Filter fltr;
            for(int i=0;i < jsonArray.length();i++){
                jsonObject = jsonArray.getJSONObject(i);
                fltr = new Filter();
                fltr.description = jsonObject.getString("d");
                fltr.hasCommandSupport = jsonObject.getBoolean("hcs");
                fltr.hasSliceThreading = (jsonObject.getInt("hst") == 1);
                fltr.hasTimelineSupport = (jsonObject.getInt("hts") == 1);
                fltr.name = jsonObject.getString("n");
                fltr.type = jsonObject.getString("t");
                vecFilters.add(i,fltr);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return vecFilters;
    }

    public ArrayList<PixelFormat> getPixelFormats() {
        ArrayList<PixelFormat> vecFormats = new ArrayList<>();
        String json = jni_getPixelFormats();
        try {
            JSONArray jsonArray = new JSONArray(json);
            JSONObject jsonObject;
            PixelFormat pixFrmt;
            for(int i=0;i < jsonArray.length();i++){
                jsonObject = jsonArray.getJSONObject(i);
                pixFrmt = new PixelFormat();
                pixFrmt.bitsPerPixel = jsonObject.getInt("bitsPerPixel");
                pixFrmt.name = jsonObject.getString("name");
                pixFrmt.isInput = jsonObject.getBoolean("isInput");
                pixFrmt.isOutput = jsonObject.getBoolean("isOutput");
                pixFrmt.isHardwareAccelerated = jsonObject.getBoolean("isHardwareAccelerated");
                pixFrmt.isPalleted = jsonObject.getBoolean("isPalleted");
                pixFrmt.isBitStream = jsonObject.getBoolean("isBitStream");
                pixFrmt.numComponents = jsonObject.getInt("numComponents");
                vecFormats.add(i,pixFrmt);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return vecFormats;
    }
    public Layouts getLayouts() {
        Layouts layouts = new Layouts();
        String json = jni_getLayouts();
        JSONObject jsonObject = null;
        try {
            jsonObject = new JSONObject(json);
            JSONArray jsonArrayI = (JSONArray) jsonObject.get("individual");
            JSONArray jsonArrayS = (JSONArray) jsonObject.get("standard");
            JSONObject jsonObjectI;
            JSONObject jsonObjectS;
            Layout lyout;
            for(int i=0;i < jsonArrayI.length();i++){
                jsonObjectI = jsonArrayI.getJSONObject(i);
                lyout = new Layout();
                lyout.name = jsonObjectI.getString("n");
                lyout.description = jsonObjectI.getString("d");
                layouts.individual.add(i,lyout);
            }

            for(int i=0;i < jsonArrayS.length();i++){
                jsonObjectS = jsonArrayS.getJSONObject(i);
                lyout = new Layout();
                lyout.name = jsonObjectS.getString("n");
                lyout.description = jsonObjectS.getString("d");
                layouts.standard.add(i,lyout);
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }



        return layouts;
    }
    public ArrayList<Color> getColors() {
        ArrayList<Color> vecColors = new ArrayList<>();
        String json = jni_getColors();
        try {
            JSONArray jsonArray = new JSONArray(json);
            JSONObject jsonObject;
            Color clr;
            for(int i=0;i < jsonArray.length();i++){
                jsonObject = jsonArray.getJSONObject(i);
                clr = new Color();
                clr.name = jsonObject.getString("n");
                clr.value = jsonObject.getString("v");
                vecColors.add(i,clr);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return vecColors;
    }

    public Protocols getProtocols() {
        Protocols protocols = new Protocols();
        String json = jni_getProtocols();
        JSONObject jsonObject = null;
        try {
            jsonObject = new JSONObject(json);
            JSONArray jsonArrayI = (JSONArray) jsonObject.get("i");
            JSONArray jsonArrayO = (JSONArray) jsonObject.get("o");
            JSONObject jsonObjectI;
            JSONObject jsonObjectO;

            Protocol protocol;
            for(int i=0;i < jsonArrayI.length();i++){
                jsonObjectI = jsonArrayI.getJSONObject(i);
                protocol = new Protocol();
                protocol.name = jsonObjectI.getString("n");
                protocols.inputs.add(i,protocol);
            }

            for(int i=0;i < jsonArrayO.length();i++){
                jsonObjectO = jsonArrayO.getJSONObject(i);
                protocol = new Protocol();
                protocol.name = jsonObjectO.getString("n");
                protocols.outputs.add(i,protocol);
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }

        return protocols;
    }

    public ArrayList<BitStreamFilter> getBitStreamFilters() {
        ArrayList<BitStreamFilter> vecBsfs = new ArrayList<>();
        String json = jni_getBitStreamFilters();
        try {
            JSONArray jsonArray = new JSONArray(json);
            JSONObject jsonObject;
            BitStreamFilter bsf;
            for(int i=0;i < jsonArray.length();i++){
                jsonObject = jsonArray.getJSONObject(i);
                bsf = new BitStreamFilter();
                bsf.name = jsonObject.getString("n");
                vecBsfs.add(i,bsf);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return vecBsfs;
    }

    public ArrayList<Codec> getCodecs() {
        ArrayList<Codec> vecCodecs = new ArrayList<>();
        String json = jni_getCodecs();
        try {
            JSONArray jsonArray = new JSONArray(json);
            JSONObject jsonObject;
            Codec codec;
            for(int i=0;i < jsonArray.length();i++){
                jsonObject = jsonArray.getJSONObject(i);
                codec = new Codec();
                codec.name = jsonObject.getString("n");
                codec.nameLong = jsonObject.getString("nl");
                codec.hasDecoder = jsonObject.getBoolean("d");
                codec.hasEncoder = jsonObject.getBoolean("e");

                if(jsonObject.has("v"))
                    codec.isVideo = jsonObject.getBoolean("v");
                if(jsonObject.has("a"))
                    codec.isAudio = jsonObject.getBoolean("a");
                if(jsonObject.has("s"))
                    codec.isSubtitles = jsonObject.getBoolean("s");
                if(jsonObject.has("ly"))
                    codec.isLossy = jsonObject.getBoolean("ly");
                if(jsonObject.has("ll"))
                    codec.isLossless = jsonObject.getBoolean("ll");
                if(jsonObject.has("in"))
                    codec.isIntraFrameOnly = jsonObject.getBoolean("in");

                vecCodecs.add(i,codec);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return vecCodecs;
    }

    public ArrayList<Decoder> getDecoders() {
        ArrayList<Decoder> vecDecoders = new ArrayList<>();
        String json = jni_getDecoders();
        try {
            JSONArray jsonArray = new JSONArray(json);
            JSONObject jsonObject;
            Decoder decoder;
            for(int i=0;i < jsonArray.length();i++){
                jsonObject = jsonArray.getJSONObject(i);
                decoder = new Decoder();
                decoder.name = jsonObject.getString("n");
                decoder.nameLong = jsonObject.getString("nl");
                if(jsonObject.has("v"))
                    decoder.isVideo = jsonObject.getBoolean("v");
                if(jsonObject.has("a"))
                    decoder.isAudio = jsonObject.getBoolean("a");
                if(jsonObject.has("s"))
                    decoder.isSubtitles = jsonObject.getBoolean("s");
                if(jsonObject.has("flm"))
                    decoder.hasFrameLevelMultiThreading = jsonObject.getBoolean("flm");
                if(jsonObject.has("slm"))
                    decoder.hasSliceLevelMultiThreading = jsonObject.getBoolean("slm");
                if(jsonObject.has("ex"))
                    decoder.isExperimental = jsonObject.getBoolean("ex");
                if(jsonObject.has("hb"))
                    decoder.supportsDrawHorizBand = jsonObject.getBoolean("hb");
                if(jsonObject.has("dr"))
                    decoder.supportsDirectRendering = jsonObject.getBoolean("dr");
                vecDecoders.add(i,decoder);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return vecDecoders;
    }

    public ArrayList<Encoder> getEncoders() {
        ArrayList<Encoder> vecEncoders = new ArrayList<>();
        String json = jni_getEncoders();
        try {
            JSONArray jsonArray = new JSONArray(json);
            JSONObject jsonObject;
            Encoder encoder;
            for(int i=0;i < jsonArray.length();i++){
                jsonObject = jsonArray.getJSONObject(i);
                encoder = new Encoder();
                encoder.name = jsonObject.getString("n");
                encoder.nameLong = jsonObject.getString("nl");
                if(jsonObject.has("v"))
                    encoder.isVideo = jsonObject.getBoolean("v");
                if(jsonObject.has("a"))
                    encoder.isAudio = jsonObject.getBoolean("a");
                if(jsonObject.has("s"))
                    encoder.isSubtitles = jsonObject.getBoolean("s");
                if(jsonObject.has("flm"))
                    encoder.hasFrameLevelMultiThreading = jsonObject.getBoolean("flm");
                if(jsonObject.has("slm"))
                    encoder.hasSliceLevelMultiThreading = jsonObject.getBoolean("slm");
                if(jsonObject.has("ex"))
                    encoder.isExperimental = jsonObject.getBoolean("ex");
                if(jsonObject.has("hb"))
                    encoder.supportsDrawHorizBand = jsonObject.getBoolean("hb");
                if(jsonObject.has("dr"))
                    encoder.supportsDirectRendering = jsonObject.getBoolean("dr");
                vecEncoders.add(i,encoder);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return vecEncoders;
    }

    public ArrayList<HardwareAcceleration> getHardwareAccelerations(){
        ArrayList<HardwareAcceleration> vecHW = new ArrayList<>();
        String json = jni_getHardwareAccelerations();
        if(json != null && !json.isEmpty()){//TODO check valid JSON on all
            try {
                JSONArray jsonArray = new JSONArray(json);
                JSONObject jsonObject;
                HardwareAcceleration hw;
                for(int i=0;i < jsonArray.length();i++){
                    jsonObject = jsonArray.getJSONObject(i);
                    hw = new HardwareAcceleration();
                    hw.name = jsonObject.getString("n");
                    vecHW.add(i,hw);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return vecHW;
    }

    public ArrayList<Device> getDevices() {
        ArrayList<Device> vecDevices = new ArrayList<>();
        String json = jni_getDevices();
        if(json != null && !json.isEmpty()) {
            try {
                JSONArray jsonArray = new JSONArray(json);
                JSONObject jsonObject;
                Device device;
                for (int i = 0; i < jsonArray.length(); i++) {
                    jsonObject = jsonArray.getJSONObject(i);
                    device = new Device();
                    device.name = jsonObject.getString("n");
                    device.nameLong = jsonObject.getString("nl");
                    device.demuxing = jsonObject.getBoolean("d");
                    device.muxing = jsonObject.getBoolean("m");
                    vecDevices.add(i, device);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return vecDevices;
    }

    public ArrayList<AvailableFormat> getAvailableFormats(){
        ArrayList<AvailableFormat> vecFormats = new ArrayList<>();
        String json = jni_getAvailableFormats();
        if(json != null && !json.isEmpty()) {
            try {
                JSONArray jsonArray = new JSONArray(json);
                JSONObject jsonObject;
                AvailableFormat availableFormat;
                for (int i = 0; i < jsonArray.length(); i++) {
                    jsonObject = jsonArray.getJSONObject(i);
                    availableFormat = new AvailableFormat();
                    availableFormat.name = jsonObject.getString("n");
                    availableFormat.nameLong = jsonObject.getString("nl");
                    availableFormat.demuxing = jsonObject.getBoolean("d");
                    availableFormat.muxing = jsonObject.getBoolean("m");
                    vecFormats.add(i, availableFormat);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return vecFormats;
    }

    public ArrayList<SampleFormat> getSampleFormats() {
        ArrayList<SampleFormat> vecFormats = new ArrayList<>();
        String json = jni_getSampleFormats();
        if(json != null && !json.isEmpty()) {
            try {
                JSONArray jsonArray = new JSONArray(json);
                JSONObject jsonObject;
                SampleFormat sampleFormat;
                for (int i = 0; i < jsonArray.length(); i++) {
                    if(jsonArray.isNull(i)) continue;
                    jsonObject = jsonArray.getJSONObject(i);
                    sampleFormat = new SampleFormat();
                    sampleFormat.name = jsonObject.getString("n");
                    sampleFormat.depth = jsonObject.getString("d");
                    vecFormats.add(sampleFormat);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return vecFormats;
    }

    public String getLicense() {
        return jni_getLicense();
    }

    public String getVersion() {
        return jni_getVersion();
    }
    public String getBuildConfiguration() {
        return jni_getBuildConfiguration();
    }

    public void encode(String[] path) {
        jni_encode(path);
    }

    public void setLogLevel(int level) {
        jni_setLogLevel(level);
    }

    public Boolean cancelEncode() {
        jni_cancelEncode();
        return true;
        //return extensionContext.call("cancelEncode");
    }

    public Boolean pauseEncode(Boolean value) {
        jni_pauseEncode(value);
        return true;
        //return extensionContext.call("pauseEncode",value);
    }
    private native void jni_triggerProbeInfo(String filename, String playlist);
    private native void jni_getProbeInfo(String filename, String playlist);
    private native String jni_getFilters();
    private native String jni_getPixelFormats();
    private native String jni_getLayouts();
    private native String jni_getVersion();
    private native String jni_getColors();
    private native String jni_getProtocols();
    private native String jni_getLicense();
    private native String jni_getBuildConfiguration();
    private native String jni_getHardwareAccelerations();
    private native String jni_getDevices();
    private native String jni_getAvailableFormats();
    private native String jni_getSampleFormats();
    private native String jni_getBitStreamFilters();
    private native String jni_getCodecs();
    private native String jni_getDecoders();
    private native String jni_getEncoders();
    private native void jni_encode(String[] path);
    private native void jni_setLogLevel(int level);
    private native void jni_cancelEncode();
    private native void jni_pauseEncode(Boolean value);
    static {
        System.loadLibrary("avane-lib");
    }
}
