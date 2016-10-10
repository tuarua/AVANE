package com.tuarua;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.tuarua.avane.android.LibAVANE;
import com.tuarua.avane.android.Progress;
import com.tuarua.avane.android.constants.LogLevel;
import com.tuarua.avane.android.events.Event;
import com.tuarua.avane.android.events.IEventHandler;
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
import com.tuarua.avane.android.probe.AudioStream;
import com.tuarua.avane.android.probe.Format;
import com.tuarua.avane.android.probe.Probe;
import com.tuarua.avane.android.probe.SubtitleStream;
import com.tuarua.avane.android.probe.VideoStream;
import com.tuarua.utils.ANEhelper;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * Created by Eoin Landy on 09/10/2016.
 */
public class AVANEContext extends FREContext {
    private int logLevel = LogLevel.QUIET;
    private ANEhelper aneHelper = ANEhelper.getInstance();
    private LibAVANE libAVANE = LibAVANE.getInstance();


    public AVANEContext(){
        libAVANE.eventDispatcher.addEventListener(Event.TRACE, new IEventHandler(){
            @Override
            public void callback(Event event) {
                trace((String) event.getParams());
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.INFO, new IEventHandler(){
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync(String.valueOf(event.getParams()),Event.INFO);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.INFO_HTML, new IEventHandler(){
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync(String.valueOf(event.getParams()),Event.INFO_HTML);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.ON_PROBE_INFO_AVAILABLE, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync("",Event.ON_PROBE_INFO);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.NO_PROBE_INFO, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync("",Event.NO_PROBE_INFO);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_START, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync("",Event.ON_ENCODE_START);
            }
        });

        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_ERROR, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync(String.valueOf(event.getParams()),Event.ON_ENCODE_ERROR);
            }
        });

        libAVANE.eventDispatcher.addEventListener(Event.ON_ERROR_MESSAGE, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync(String.valueOf(event.getParams()),Event.ON_ERROR_MESSAGE);
            }
        });

        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_FINISH, new IEventHandler(){
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync("",Event.ON_ENCODE_FINISH);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_PROGRESS, new IEventHandler() {
            @Override
            public void callback(Event event) {
                final Progress progress = (Progress) event.getParams();
                JSONObject obj = new JSONObject();
                try {
                    obj.put("bitrate",progress.bitrate);
                    obj.put("frame",progress.frame);
                    obj.put("fps",progress.fps);
                    obj.put("secs",progress.secs);
                    obj.put("size",progress.size);
                    obj.put("speed",progress.speed);
                    obj.put("us",progress.us);
                    dispatchStatusEventAsync(obj.toString(),Event.ON_ENCODE_PROGRESS);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        });

    }


    @Override
    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> functionsToSet = new HashMap<String, FREFunction>();
        functionsToSet.put("isSupported",new isSupported());
        functionsToSet.put("setLogLevel",new setLogLevel());
        functionsToSet.put("getLayouts",new getLayouts());
        functionsToSet.put("getColors",new getColors());
        functionsToSet.put("getProtocols",new getProtocols());
        functionsToSet.put("getFilters",new getFilters());
        functionsToSet.put("getPixelFormats",new getPixelFormats());
        functionsToSet.put("getBitStreamFilters",new getBitStreamFilters());
        functionsToSet.put("getDecoders",new getDecoders());
        functionsToSet.put("getEncoders",new getEncoders());
        functionsToSet.put("getCodecs",new getCodecs());
        functionsToSet.put("getHardwareAccelerations",new getHardwareAccelerations());
        functionsToSet.put("getDevices",new getDevices());
        functionsToSet.put("getAvailableFormats",new getAvailableFormats());
        functionsToSet.put("getBuildConfiguration",new getBuildConfiguration());
        functionsToSet.put("getLicense",new getLicense());
        functionsToSet.put("getVersion",new getVersion());
        functionsToSet.put("getSampleFormats",new getSampleFormats());
        functionsToSet.put("triggerProbeInfo",new triggerProbeInfo());
        functionsToSet.put("getProbeInfo",new getProbeInfo());
        functionsToSet.put("encode",new encode());
        functionsToSet.put("cancelEncode",new cancelEncode());
        functionsToSet.put("pauseEncode",new pauseEncode());

        return functionsToSet;
    }
    private class isSupported implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return aneHelper.getFREObjectFromBool(true);
        }
    }

    private class setLogLevel implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            logLevel = aneHelper.getIntFromFREObject(freObjects[0]);
            return null;
        }
    }

    private class getLayouts implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            Layouts layouts = libAVANE.getLayouts();

            FREObject objLayouts;
            objLayouts = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Layouts",null);

            FREArray vecIndividual;
            vecIndividual = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Layout>",null);

            FREArray vecStandard;
            vecStandard = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Layout>",null);

            Layout layout;
            FREObject objLayout;
            for (int i = 0; i < layouts.individual.size(); ++i) {
                layout = layouts.individual.get(i);
                objLayout = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Layout",null);
                aneHelper.setFREObjectProperty(objLayout,"name",aneHelper.getFREObjectFromString(layout.name));
                aneHelper.setFREObjectProperty(objLayout,"description",aneHelper.getFREObjectFromString(layout.description));
                try {
                    vecIndividual.setObjectAt(i,objLayout);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            aneHelper.setFREObjectProperty(objLayouts,"individual",vecIndividual);

            for (int i = 0; i < layouts.standard.size(); ++i) {
                layout = layouts.standard.get(i);
                objLayout = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Layout",null);
                aneHelper.setFREObjectProperty(objLayout,"name",aneHelper.getFREObjectFromString(layout.name));
                aneHelper.setFREObjectProperty(objLayout,"description",aneHelper.getFREObjectFromString(layout.description));
                try {
                    vecStandard.setObjectAt(i,objLayout);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            aneHelper.setFREObjectProperty(objLayouts,"standard",vecStandard);

            return objLayouts;
        }
    }

    private class getColors implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Color>",null);
            ArrayList<Color> itms = libAVANE.getColors();
            Color itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Color",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                aneHelper.setFREObjectProperty(obj,"value",aneHelper.getFREObjectFromString(itm.value));
                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class pauseEncode implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            libAVANE.pauseEncode(aneHelper.getBoolFromFREObject(freObjects[0]));
            return null;
        }
    }

    private class cancelEncode implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            libAVANE.cancelEncode();
            return null;
        }
    }

    private class encode implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray freParams = (FREArray) freObjects[0];
            long numParams = aneHelper.getFREObjectArrayLength(freParams);
            FREObject valueAs;
            String[] params = new String[(int) numParams];

            for (int i = 0; i < numParams; i++) {
                try {
                    valueAs = freParams.getObjectAt(i);
                    params[i] = aneHelper.getStringFromFREObject(valueAs);
                } catch (FREInvalidObjectException | FREWrongThreadException e) {
                    e.printStackTrace();
                }
            }

            libAVANE.encode(params);

            return null;
        }
    }

    private class getProbeInfo implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            Probe probe = libAVANE.getProbeInfo();
            FREObject ret;
            ret = aneHelper.createFREObject("com.tuarua.ffprobe.Probe",null);

            if (probe != null){
                FREArray vecVideoStreams = null;
                FREArray vecAudioStreams = null;
                FREArray vecSubtitleStreams = null;
                vecVideoStreams = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffprobe.VideoStream>",null);
                vecAudioStreams = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffprobe.AudioStream>",null);
                vecSubtitleStreams = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffprobe.SubtitleStream>",null);

                VideoStream vs;
                FREObject obj;
                for (int i = 0; i < probe.videoStreams.size(); i++) {
                    vs = probe.videoStreams.get(i);
                    obj = aneHelper.createFREObject("com.tuarua.ffprobe.VideoStream",null);

                    ///////  common /////////////////
                    aneHelper.setFREObjectProperty(obj,"index",aneHelper.getFREObjectFromInt(vs.index));
                    aneHelper.setFREObjectProperty(obj,"codecTag",aneHelper.getFREObjectFromInt(vs.codecTag));
                    aneHelper.setFREObjectProperty(obj,"id",aneHelper.getFREObjectFromString(vs.id));
                    aneHelper.setFREObjectProperty(obj,"codecName",aneHelper.getFREObjectFromString(vs.codecName));
                    aneHelper.setFREObjectProperty(obj,"codecLongName",aneHelper.getFREObjectFromString(vs.codecLongName));
                    aneHelper.setFREObjectProperty(obj,"profile",aneHelper.getFREObjectFromString(vs.profile));
                    aneHelper.setFREObjectProperty(obj,"codecType",aneHelper.getFREObjectFromString(vs.codecType));
                    aneHelper.setFREObjectProperty(obj,"codecTimeBase",aneHelper.getFREObjectFromString(vs.codecTimeBase));
                    aneHelper.setFREObjectProperty(obj,"codecTagString",aneHelper.getFREObjectFromString(vs.codecTagString));
                    aneHelper.setFREObjectProperty(obj,"timeBase",aneHelper.getFREObjectFromString(vs.timeBase));
                    aneHelper.setFREObjectProperty(obj,"duration",aneHelper.getFREObjectFromDouble(vs.duration));
                    aneHelper.setFREObjectProperty(obj,"durationTimestamp",aneHelper.getFREObjectFromDouble(vs.durationTimestamp));
                    aneHelper.setFREObjectProperty(obj,"realFrameRate",aneHelper.getFREObjectFromDouble(vs.realFrameRate));
                    aneHelper.setFREObjectProperty(obj,"averageFrameRate",aneHelper.getFREObjectFromDouble(vs.averageFrameRate));
                    aneHelper.setFREObjectProperty(obj,"startPTS",aneHelper.getFREObjectFromDouble(vs.startPTS));
                    aneHelper.setFREObjectProperty(obj,"startTime",aneHelper.getFREObjectFromDouble(vs.startTime));
                    aneHelper.setFREObjectProperty(obj,"bitRate",aneHelper.getFREObjectFromDouble(vs.bitRate));
                    aneHelper.setFREObjectProperty(obj,"maxBitRate",aneHelper.getFREObjectFromDouble(vs.maxBitRate));
                    aneHelper.setFREObjectProperty(obj,"bitsPerRawSample",aneHelper.getFREObjectFromDouble(vs.bitsPerRawSample));
                    aneHelper.setFREObjectProperty(obj,"numFrames",aneHelper.getFREObjectFromDouble(vs.numFrames));
                    FREObject tagsObj;
                    tagsObj = aneHelper.createFREObject("Object",null);

                    if(vs.tags.size() > 0){
                        for (Map.Entry<String, String> entry : vs.tags.entrySet()) {
                            String key = entry.getKey();
                            String value = entry.getValue();
                            aneHelper.setFREObjectProperty(tagsObj,key,aneHelper.getFREObjectFromString(value));
                        }
                        aneHelper.setFREObjectProperty(obj,"tags",tagsObj);
                    }

                    /////////////
                    aneHelper.setFREObjectProperty(obj,"width",aneHelper.getFREObjectFromInt(vs.width));
                    aneHelper.setFREObjectProperty(obj,"height",aneHelper.getFREObjectFromInt(vs.height));
                    aneHelper.setFREObjectProperty(obj,"codedWidth",aneHelper.getFREObjectFromInt(vs.codedWidth));
                    aneHelper.setFREObjectProperty(obj,"codedWidth",aneHelper.getFREObjectFromInt(vs.codedWidth));
                    aneHelper.setFREObjectProperty(obj,"hasBframes",aneHelper.getFREObjectFromInt(vs.hasBframes));
                    aneHelper.setFREObjectProperty(obj,"level",aneHelper.getFREObjectFromInt(vs.level));
                    aneHelper.setFREObjectProperty(obj,"refs",aneHelper.getFREObjectFromInt(vs.refs));
                    aneHelper.setFREObjectProperty(obj,"sampleAspectRatio",aneHelper.getFREObjectFromString(vs.sampleAspectRatio));
                    aneHelper.setFREObjectProperty(obj,"displayAspectRatio",aneHelper.getFREObjectFromString(vs.displayAspectRatio));
                    aneHelper.setFREObjectProperty(obj,"pixelFormat",aneHelper.getFREObjectFromString(vs.pixelFormat));
                    aneHelper.setFREObjectProperty(obj,"colorRange",aneHelper.getFREObjectFromString(vs.colorRange));
                    aneHelper.setFREObjectProperty(obj,"colorSpace",aneHelper.getFREObjectFromString(vs.colorSpace));
                    aneHelper.setFREObjectProperty(obj,"colorTransfer",aneHelper.getFREObjectFromString(vs.colorTransfer));
                    aneHelper.setFREObjectProperty(obj,"colorPrimaries",aneHelper.getFREObjectFromString(vs.colorPrimaries));
                    aneHelper.setFREObjectProperty(obj,"chromaLocation",aneHelper.getFREObjectFromString(vs.chromaLocation));
                    aneHelper.setFREObjectProperty(obj,"timecode",aneHelper.getFREObjectFromString(vs.timecode));
                    try {
                        vecVideoStreams.setObjectAt(i,obj);
                    } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                        trace("error: "+e.getMessage());
                        e.printStackTrace();
                    }
                }
                aneHelper.setFREObjectProperty(ret,"videoStreams",vecVideoStreams);


                AudioStream as;
                for (int i = 0; i < probe.audioStreams.size(); i++) {
                    as = probe.audioStreams.get(i);
                    obj = aneHelper.createFREObject("com.tuarua.ffprobe.AudioStream", null);

                    ///////  common /////////////////
                    aneHelper.setFREObjectProperty(obj,"index",aneHelper.getFREObjectFromInt(as.index));
                    aneHelper.setFREObjectProperty(obj,"codecTag",aneHelper.getFREObjectFromInt(as.codecTag));
                    aneHelper.setFREObjectProperty(obj,"id",aneHelper.getFREObjectFromString(as.id));
                    aneHelper.setFREObjectProperty(obj,"codecName",aneHelper.getFREObjectFromString(as.codecName));
                    aneHelper.setFREObjectProperty(obj,"codecLongName",aneHelper.getFREObjectFromString(as.codecLongName));
                    aneHelper.setFREObjectProperty(obj,"profile",aneHelper.getFREObjectFromString(as.profile));
                    aneHelper.setFREObjectProperty(obj,"codecType",aneHelper.getFREObjectFromString(as.codecType));
                    aneHelper.setFREObjectProperty(obj,"codecTimeBase",aneHelper.getFREObjectFromString(as.codecTimeBase));
                    aneHelper.setFREObjectProperty(obj,"codecTagString",aneHelper.getFREObjectFromString(as.codecTagString));
                    aneHelper.setFREObjectProperty(obj,"timeBase",aneHelper.getFREObjectFromString(as.timeBase));
                    aneHelper.setFREObjectProperty(obj,"duration",aneHelper.getFREObjectFromDouble(as.duration));
                    aneHelper.setFREObjectProperty(obj,"durationTimestamp",aneHelper.getFREObjectFromDouble(as.durationTimestamp));
                    aneHelper.setFREObjectProperty(obj,"realFrameRate",aneHelper.getFREObjectFromDouble(as.realFrameRate));
                    aneHelper.setFREObjectProperty(obj,"averageFrameRate",aneHelper.getFREObjectFromDouble(as.averageFrameRate));
                    aneHelper.setFREObjectProperty(obj,"startPTS",aneHelper.getFREObjectFromDouble(as.startPTS));
                    aneHelper.setFREObjectProperty(obj,"startTime",aneHelper.getFREObjectFromDouble(as.startTime));
                    aneHelper.setFREObjectProperty(obj,"bitRate",aneHelper.getFREObjectFromDouble(as.bitRate));
                    aneHelper.setFREObjectProperty(obj,"maxBitRate",aneHelper.getFREObjectFromDouble(as.maxBitRate));
                    aneHelper.setFREObjectProperty(obj,"bitsPerRawSample",aneHelper.getFREObjectFromDouble(as.bitsPerRawSample));
                    aneHelper.setFREObjectProperty(obj,"numFrames",aneHelper.getFREObjectFromDouble(as.numFrames));
                    FREObject tagsObj;
                    if(as.tags.size() > 0){
                        tagsObj = aneHelper.createFREObject("Object",null);
                        for (Map.Entry<String, String> entry : as.tags.entrySet()) {
                            String key = entry.getKey();
                            String value = entry.getValue();
                            aneHelper.setFREObjectProperty(tagsObj,key,aneHelper.getFREObjectFromString(value));
                        }
                        aneHelper.setFREObjectProperty(obj,"tags",tagsObj);
                    }
                    /////////////

                    aneHelper.setFREObjectProperty(obj,"sampleFormat",aneHelper.getFREObjectFromString(as.sampleFormat));
                    aneHelper.setFREObjectProperty(obj,"channelLayout",aneHelper.getFREObjectFromString(as.channelLayout));
                    aneHelper.setFREObjectProperty(obj,"sampleRate",aneHelper.getFREObjectFromInt(as.sampleRate));
                    aneHelper.setFREObjectProperty(obj,"channels",aneHelper.getFREObjectFromInt(as.channels));
                    aneHelper.setFREObjectProperty(obj,"bitsPerSample",aneHelper.getFREObjectFromInt(as.bitsPerSample));

                    try {
                        vecAudioStreams.setObjectAt(i,obj);
                        trace("10");
                    } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                        trace("error: "+e.getMessage());
                        e.printStackTrace();
                    }

                }
                aneHelper.setFREObjectProperty(ret,"audioStreams",vecAudioStreams);

                SubtitleStream ss;
                for (int i = 0; i < probe.subtitleStreams.size(); i++) {
                    ss = probe.subtitleStreams.get(i);
                    obj = aneHelper.createFREObject("com.tuarua.ffprobe.SubtitleStream", null);

                    ///////  common /////////////////
                    aneHelper.setFREObjectProperty(obj,"index",aneHelper.getFREObjectFromInt(ss.index));
                    aneHelper.setFREObjectProperty(obj,"codecTag",aneHelper.getFREObjectFromInt(ss.codecTag));
                    aneHelper.setFREObjectProperty(obj,"id",aneHelper.getFREObjectFromString(ss.id));
                    aneHelper.setFREObjectProperty(obj,"codecName",aneHelper.getFREObjectFromString(ss.codecName));
                    aneHelper.setFREObjectProperty(obj,"codecLongName",aneHelper.getFREObjectFromString(ss.codecLongName));
                    aneHelper.setFREObjectProperty(obj,"profile",aneHelper.getFREObjectFromString(ss.profile));
                    aneHelper.setFREObjectProperty(obj,"codecType",aneHelper.getFREObjectFromString(ss.codecType));
                    aneHelper.setFREObjectProperty(obj,"codecTimeBase",aneHelper.getFREObjectFromString(ss.codecTimeBase));
                    aneHelper.setFREObjectProperty(obj,"codecTagString",aneHelper.getFREObjectFromString(ss.codecTagString));
                    aneHelper.setFREObjectProperty(obj,"timeBase",aneHelper.getFREObjectFromString(ss.timeBase));
                    aneHelper.setFREObjectProperty(obj,"duration",aneHelper.getFREObjectFromDouble(ss.duration));
                    aneHelper.setFREObjectProperty(obj,"durationTimestamp",aneHelper.getFREObjectFromDouble(ss.durationTimestamp));
                    aneHelper.setFREObjectProperty(obj,"realFrameRate",aneHelper.getFREObjectFromDouble(ss.realFrameRate));
                    aneHelper.setFREObjectProperty(obj,"averageFrameRate",aneHelper.getFREObjectFromDouble(ss.averageFrameRate));
                    aneHelper.setFREObjectProperty(obj,"startPTS",aneHelper.getFREObjectFromDouble(ss.startPTS));
                    aneHelper.setFREObjectProperty(obj,"startTime",aneHelper.getFREObjectFromDouble(ss.startTime));
                    aneHelper.setFREObjectProperty(obj,"bitRate",aneHelper.getFREObjectFromDouble(ss.bitRate));
                    aneHelper.setFREObjectProperty(obj,"maxBitRate",aneHelper.getFREObjectFromDouble(ss.maxBitRate));
                    aneHelper.setFREObjectProperty(obj,"bitsPerRawSample",aneHelper.getFREObjectFromDouble(ss.bitsPerRawSample));
                    aneHelper.setFREObjectProperty(obj,"numFrames",aneHelper.getFREObjectFromDouble(ss.numFrames));
                    FREObject tagsObj;
                    if(ss.tags.size() > 0){
                        tagsObj = aneHelper.createFREObject("Object",null);
                        for (Map.Entry<String, String> entry : ss.tags.entrySet()) {
                            String key = entry.getKey();
                            String value = entry.getValue();
                            aneHelper.setFREObjectProperty(tagsObj,key,aneHelper.getFREObjectFromString(value));
                        }
                        aneHelper.setFREObjectProperty(obj,"tags",tagsObj);
                    }
                    /////////////

                    aneHelper.setFREObjectProperty(obj,"width",aneHelper.getFREObjectFromInt(ss.width));
                    aneHelper.setFREObjectProperty(obj,"height",aneHelper.getFREObjectFromInt(ss.height));

                    try {
                        vecSubtitleStreams.setObjectAt(i,obj);
                        trace("ss 10");
                    } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                        trace("error: "+e.getMessage());
                        e.printStackTrace();
                    }

                }

                aneHelper.setFREObjectProperty(ret,"subtitleStreams",vecSubtitleStreams);

                //Format
                FREObject objFormat;
                objFormat = aneHelper.createFREObject("com.tuarua.ffprobe.Format",null);
                aneHelper.setFREObjectProperty(objFormat,"filename",aneHelper.getFREObjectFromString(probe.format.filename));
                aneHelper.setFREObjectProperty(objFormat,"formatLongName",aneHelper.getFREObjectFromString(probe.format.formatLongName));
                aneHelper.setFREObjectProperty(objFormat,"formatName",aneHelper.getFREObjectFromString(probe.format.formatName));
                aneHelper.setFREObjectProperty(objFormat,"numStreams",aneHelper.getFREObjectFromInt(probe.format.numStreams));
                aneHelper.setFREObjectProperty(objFormat,"numPrograms",aneHelper.getFREObjectFromInt(probe.format.numPrograms));
                aneHelper.setFREObjectProperty(objFormat,"size",aneHelper.getFREObjectFromInt(probe.format.size));
                aneHelper.setFREObjectProperty(objFormat,"bitRate",aneHelper.getFREObjectFromInt(probe.format.bitRate));
                aneHelper.setFREObjectProperty(objFormat,"probeScore",aneHelper.getFREObjectFromInt(probe.format.probeScore));
                aneHelper.setFREObjectProperty(objFormat,"startTime",aneHelper.getFREObjectFromDouble(probe.format.startTime));
                aneHelper.setFREObjectProperty(objFormat,"duration",aneHelper.getFREObjectFromDouble(probe.format.duration));

                //convert to helper hashMap to Object //TODO
                FREObject tagsObj;
                if(probe.format.tags.size() > 0){
                    tagsObj = aneHelper.createFREObject("Object",null);
                    for (Map.Entry<String, String> entry : probe.format.tags.entrySet()) {
                        String key = entry.getKey();
                        String value = entry.getValue();
                        aneHelper.setFREObjectProperty(tagsObj,key,aneHelper.getFREObjectFromString(value));
                    }
                    aneHelper.setFREObjectProperty(objFormat,"tags",tagsObj);
                }

                aneHelper.setFREObjectProperty(ret,"format",objFormat);

            }

            return ret;
        }
    }

    private class triggerProbeInfo implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            libAVANE.triggerProbeInfo(aneHelper.getStringFromFREObject(freObjects[0]));
            return null;
        }
    }

    private class getSampleFormats implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.SampleFormat>",null);
            ArrayList<SampleFormat> itms = libAVANE.getSampleFormats();
            SampleFormat itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.SampleFormat",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                aneHelper.setFREObjectProperty(obj,"depth",aneHelper.getFREObjectFromString(itm.depth));
                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class getVersion implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return aneHelper.getFREObjectFromString(libAVANE.getVersion());
        }
    }

    private class getProtocols implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            Protocols protocols = libAVANE.getProtocols();

            FREObject ret;
            ret = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Protocols",null);

            FREArray vecInputProtocols;
            vecInputProtocols = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Protocol>",null);

            FREArray vecOutputProtocols;
            vecOutputProtocols = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Protocol>",null);

            Protocol itm;
            FREObject obj;
            for (int i = 0; i < protocols.inputs.size(); ++i) {
                itm = protocols.inputs.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Protocol",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                try {
                    vecInputProtocols.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            aneHelper.setFREObjectProperty(ret,"inputs",vecInputProtocols);


            for (int i = 0; i < protocols.outputs.size(); ++i) {
                itm = protocols.outputs.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Protocol",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                try {
                    vecOutputProtocols.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            aneHelper.setFREObjectProperty(ret,"outputs",vecOutputProtocols);



            return ret;
        }
    }

    private class getFilters implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Filter>",null);
            ArrayList<Filter> itms = libAVANE.getFilters();
            Filter itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Filter",null);
                aneHelper.setFREObjectProperty(obj,"hasTimelineSupport",aneHelper.getFREObjectFromBool(itm.hasTimelineSupport));
                aneHelper.setFREObjectProperty(obj,"hasSliceThreading",aneHelper.getFREObjectFromBool(itm.hasSliceThreading));
                aneHelper.setFREObjectProperty(obj,"hasCommandSupport",aneHelper.getFREObjectFromBool(itm.hasCommandSupport));
                aneHelper.setFREObjectProperty(obj,"type",aneHelper.getFREObjectFromString(itm.type));
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                aneHelper.setFREObjectProperty(obj,"description",aneHelper.getFREObjectFromString(itm.description));
                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class getPixelFormats implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.PixelFormat>",null);
            ArrayList<PixelFormat> itms = libAVANE.getPixelFormats();
            PixelFormat itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.PixelFormat",null);
                aneHelper.setFREObjectProperty(obj,"isInput",aneHelper.getFREObjectFromBool(itm.isInput));
                aneHelper.setFREObjectProperty(obj,"isOutput",aneHelper.getFREObjectFromBool(itm.isOutput));
                aneHelper.setFREObjectProperty(obj,"isHardwareAccelerated",aneHelper.getFREObjectFromBool(itm.isHardwareAccelerated));
                aneHelper.setFREObjectProperty(obj,"isPalleted",aneHelper.getFREObjectFromBool(itm.isPalleted));
                aneHelper.setFREObjectProperty(obj,"isBitStream",aneHelper.getFREObjectFromBool(itm.isBitStream));

                aneHelper.setFREObjectProperty(obj,"numComponents",aneHelper.getFREObjectFromInt(itm.numComponents));
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                aneHelper.setFREObjectProperty(obj,"bitsPerPixel",aneHelper.getFREObjectFromInt(itm.bitsPerPixel));

                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class getBitStreamFilters implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.BitStreamFilter>",null);
            ArrayList<BitStreamFilter> itms = libAVANE.getBitStreamFilters();
            BitStreamFilter itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.BitStreamFilter",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));

                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class getDecoders implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Decoder>",null);
            ArrayList<Decoder> itms = libAVANE.getDecoders();
            Decoder itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Decoder",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                aneHelper.setFREObjectProperty(obj,"nameLong",aneHelper.getFREObjectFromString(itm.nameLong));
                aneHelper.setFREObjectProperty(obj,"isVideo",aneHelper.getFREObjectFromBool(itm.isVideo));
                aneHelper.setFREObjectProperty(obj,"isAudio",aneHelper.getFREObjectFromBool(itm.isAudio));
                aneHelper.setFREObjectProperty(obj,"isSubtitles",aneHelper.getFREObjectFromBool(itm.isSubtitles));
                aneHelper.setFREObjectProperty(obj,"hasFrameLevelMultiThreading",aneHelper.getFREObjectFromBool(itm.hasFrameLevelMultiThreading));
                aneHelper.setFREObjectProperty(obj,"hasSliceLevelMultiThreading",aneHelper.getFREObjectFromBool(itm.hasSliceLevelMultiThreading));
                aneHelper.setFREObjectProperty(obj,"isExperimental",aneHelper.getFREObjectFromBool(itm.isExperimental));
                aneHelper.setFREObjectProperty(obj,"supportsDrawHorizBand",aneHelper.getFREObjectFromBool(itm.supportsDrawHorizBand));
                aneHelper.setFREObjectProperty(obj,"supportsDirectRendering",aneHelper.getFREObjectFromBool(itm.supportsDirectRendering));
                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class getEncoders implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Encoder>",null);
            ArrayList<Encoder> itms = libAVANE.getEncoders();
            Encoder itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Encoder",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                aneHelper.setFREObjectProperty(obj,"nameLong",aneHelper.getFREObjectFromString(itm.nameLong));
                aneHelper.setFREObjectProperty(obj,"isVideo",aneHelper.getFREObjectFromBool(itm.isVideo));
                aneHelper.setFREObjectProperty(obj,"isAudio",aneHelper.getFREObjectFromBool(itm.isAudio));
                aneHelper.setFREObjectProperty(obj,"isSubtitles",aneHelper.getFREObjectFromBool(itm.isSubtitles));
                aneHelper.setFREObjectProperty(obj,"hasFrameLevelMultiThreading",aneHelper.getFREObjectFromBool(itm.hasFrameLevelMultiThreading));
                aneHelper.setFREObjectProperty(obj,"hasSliceLevelMultiThreading",aneHelper.getFREObjectFromBool(itm.hasSliceLevelMultiThreading));
                aneHelper.setFREObjectProperty(obj,"isExperimental",aneHelper.getFREObjectFromBool(itm.isExperimental));
                aneHelper.setFREObjectProperty(obj,"supportsDrawHorizBand",aneHelper.getFREObjectFromBool(itm.supportsDrawHorizBand));
                aneHelper.setFREObjectProperty(obj,"supportsDirectRendering",aneHelper.getFREObjectFromBool(itm.supportsDirectRendering));
                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class getHardwareAccelerations implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.HardwareAcceleration>",null);
            ArrayList<HardwareAcceleration> itms = libAVANE.getHardwareAccelerations();
            HardwareAcceleration itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Encoder",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class getLicense implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return aneHelper.getFREObjectFromString(libAVANE.getLicense());
        }
    }

    private class getCodecs implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Codec>",null);
            ArrayList<Codec> itms = libAVANE.getCodecs();
            Codec itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Codec",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                aneHelper.setFREObjectProperty(obj,"nameLong",aneHelper.getFREObjectFromString(itm.nameLong));
                aneHelper.setFREObjectProperty(obj,"hasDecoder",aneHelper.getFREObjectFromBool(itm.hasDecoder));
                aneHelper.setFREObjectProperty(obj,"hasEncoder",aneHelper.getFREObjectFromBool(itm.hasEncoder));
                aneHelper.setFREObjectProperty(obj,"isVideo",aneHelper.getFREObjectFromBool(itm.isVideo));
                aneHelper.setFREObjectProperty(obj,"isAudio",aneHelper.getFREObjectFromBool(itm.isAudio));
                aneHelper.setFREObjectProperty(obj,"isSubtitles",aneHelper.getFREObjectFromBool(itm.isSubtitles));
                aneHelper.setFREObjectProperty(obj,"isLossy",aneHelper.getFREObjectFromBool(itm.isLossy));
                aneHelper.setFREObjectProperty(obj,"isLossless",aneHelper.getFREObjectFromBool(itm.isLossless));
                aneHelper.setFREObjectProperty(obj,"isIntraFrameOnly",aneHelper.getFREObjectFromBool(itm.isIntraFrameOnly));

                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class getDevices implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Device>",null);
            ArrayList<Device> itms = libAVANE.getDevices();
            Device itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Device",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                aneHelper.setFREObjectProperty(obj,"nameLong",aneHelper.getFREObjectFromString(itm.nameLong));
                aneHelper.setFREObjectProperty(obj,"muxing",aneHelper.getFREObjectFromBool(itm.muxing));
                aneHelper.setFREObjectProperty(obj,"demuxing",aneHelper.getFREObjectFromBool(itm.demuxing));

                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class getAvailableFormats implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec = null;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.AvailableFormat>",null);
            ArrayList<AvailableFormat> itms = libAVANE.getAvailableFormats();
            AvailableFormat itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.AvailableFormat",null);
                aneHelper.setFREObjectProperty(obj,"name",aneHelper.getFREObjectFromString(itm.name));
                aneHelper.setFREObjectProperty(obj,"nameLong",aneHelper.getFREObjectFromString(itm.nameLong));
                aneHelper.setFREObjectProperty(obj,"muxing",aneHelper.getFREObjectFromBool(itm.muxing));
                aneHelper.setFREObjectProperty(obj,"demuxing",aneHelper.getFREObjectFromBool(itm.demuxing));

                try {
                    vec.setObjectAt(i,obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            return vec;
        }
    }

    private class getBuildConfiguration implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return aneHelper.getFREObjectFromString(libAVANE.getBuildConfiguration());
        }
    }


    private void trace(String msg){
        if(logLevel > LogLevel.QUIET){
            Log.i("com.tuarua.AVANE",String.valueOf(msg));
            dispatchStatusEventAsync(msg,"TRACE");
        }
    }
    private void trace(int msg) {
        if(logLevel > LogLevel.QUIET) {
            Log.i("com.tuarua.AVANE", String.valueOf(msg));
            dispatchStatusEventAsync(String.valueOf(msg), "TRACE");
        }
    }
    private void trace(boolean msg) {
        if(logLevel > LogLevel.QUIET) {
            Log.i("com.tuarua.AVANE", String.valueOf(msg));
            dispatchStatusEventAsync(String.valueOf(msg), "TRACE");
        }
    }

    @Override
    public void dispose() {

    }


}
