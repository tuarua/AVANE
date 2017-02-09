package com.tuarua;

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
import com.tuarua.avane.android.events.Event;
import com.tuarua.avane.android.events.IEventHandler;
import com.tuarua.avane.android.ffmpeg.constants.LogLevel;
import com.tuarua.avane.android.ffmpeg.gets.AvailableFormat;
import com.tuarua.avane.android.ffmpeg.gets.BitStreamFilter;
import com.tuarua.avane.android.ffmpeg.gets.Codec;
import com.tuarua.avane.android.ffmpeg.gets.Color;
import com.tuarua.avane.android.ffmpeg.gets.Decoder;
import com.tuarua.avane.android.ffmpeg.gets.Device;
import com.tuarua.avane.android.ffmpeg.gets.Encoder;
import com.tuarua.avane.android.ffmpeg.gets.Filter;
import com.tuarua.avane.android.ffmpeg.gets.HardwareAcceleration;
import com.tuarua.avane.android.ffmpeg.gets.Layout;
import com.tuarua.avane.android.ffmpeg.gets.Layouts;
import com.tuarua.avane.android.ffmpeg.gets.PixelFormat;
import com.tuarua.avane.android.ffmpeg.gets.Protocol;
import com.tuarua.avane.android.ffmpeg.gets.Protocols;
import com.tuarua.avane.android.ffmpeg.gets.SampleFormat;
import com.tuarua.avane.android.ffprobe.AudioStream;
import com.tuarua.avane.android.ffprobe.Probe;
import com.tuarua.avane.android.ffprobe.SubtitleStream;
import com.tuarua.avane.android.ffprobe.VideoStream;
import com.tuarua.utils.ANEhelper;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by Eoin Landy on 09/10/2016.
 */
public class AVANEContext extends FREContext {
    private int logLevel = LogLevel.QUIET;
    private ANEhelper aneHelper = ANEhelper.getInstance();
    private LibAVANE libAVANE = LibAVANE.getInstance();


    public AVANEContext() {
        libAVANE.eventDispatcher.addEventListener(Event.TRACE, new IEventHandler() {
            @Override
            public void callback(Event event) {
                trace((String) event.getParams());
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.INFO, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync(String.valueOf(event.getParams()), Event.INFO);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.INFO_HTML, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync(String.valueOf(event.getParams()), Event.INFO_HTML);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.ON_PROBE_INFO_AVAILABLE, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync("", Event.ON_PROBE_INFO);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.NO_PROBE_INFO, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync("", Event.NO_PROBE_INFO);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_START, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync("", Event.ON_ENCODE_START);
            }
        });

        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_ERROR, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync(String.valueOf(event.getParams()), Event.ON_ENCODE_ERROR);
            }
        });

        libAVANE.eventDispatcher.addEventListener(Event.ON_ERROR_MESSAGE, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync(String.valueOf(event.getParams()), Event.ON_ERROR_MESSAGE);
            }
        });

        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_FATAL, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync(String.valueOf(event.getParams()), Event.ON_ENCODE_FATAL);
            }
        });

        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_FINISH, new IEventHandler() {
            @Override
            public void callback(Event event) {
                dispatchStatusEventAsync("", Event.ON_ENCODE_FINISH);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_PROGRESS, new IEventHandler() {
            @Override
            public void callback(Event event) {
                final Progress progress = (Progress) event.getParams();
                JSONObject obj = new JSONObject();
                try {
                    obj.put("bitrate", progress.bitrate);
                    obj.put("frame", progress.frame);
                    obj.put("fps", progress.fps);
                    obj.put("secs", progress.secs);
                    obj.put("size", progress.size);
                    obj.put("speed", progress.speed);
                    obj.put("us", progress.us);
                    dispatchStatusEventAsync(obj.toString(), Event.ON_ENCODE_PROGRESS);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        });

    }


    @Override
    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> functionsToSet = new HashMap<>();
        functionsToSet.put("isSupported", new isSupported());
        functionsToSet.put("setLogLevel", new setLogLevel());
        functionsToSet.put("getLayouts", new getLayouts());
        functionsToSet.put("getColors", new getColors());
        functionsToSet.put("getProtocols", new getProtocols());
        functionsToSet.put("getFilters", new getFilters());
        functionsToSet.put("getPixelFormats", new getPixelFormats());
        functionsToSet.put("getBitStreamFilters", new getBitStreamFilters());
        functionsToSet.put("getDecoders", new getDecoders());
        functionsToSet.put("getEncoders", new getEncoders());
        functionsToSet.put("getCodecs", new getCodecs());
        functionsToSet.put("getHardwareAccelerations", new getHardwareAccelerations());
        functionsToSet.put("getDevices", new getDevices());
        functionsToSet.put("getAvailableFormats", new getAvailableFormats());
        functionsToSet.put("getBuildConfiguration", new getBuildConfiguration());
        functionsToSet.put("getLicense", new getLicense());
        functionsToSet.put("getVersion", new getVersion());
        functionsToSet.put("getSampleFormats", new getSampleFormats());
        functionsToSet.put("triggerProbeInfo", new triggerProbeInfo());
        functionsToSet.put("getProbeInfo", new getProbeInfo());
        functionsToSet.put("encode", new encode());
        functionsToSet.put("cancelEncode", new cancelEncode());
        functionsToSet.put("pauseEncode", new pauseEncode());
        functionsToSet.put("getCaptureDevices", new getCaptureDevices());

        return functionsToSet;
    }

    private class isSupported implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return aneHelper.getFREObject(true);
        }
    }

    private class setLogLevel implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            logLevel = aneHelper.getInt(freObjects[0]);
            return null;
        }
    }

    private class getLayouts implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            Layouts layouts = libAVANE.getLayouts();

            FREObject objLayouts;
            objLayouts = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Layouts", null);

            FREArray vecIndividual;
            vecIndividual = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Layout>", null);

            FREArray vecStandard;
            vecStandard = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Layout>", null);

            Layout layout;
            FREObject objLayout;
            for (int i = 0; i < layouts.individual.size(); ++i) {
                layout = layouts.individual.get(i);
                objLayout = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Layout", null);
                aneHelper.setProperty(objLayout, "name", layout.name);
                aneHelper.setProperty(objLayout, "description", layout.description);
                try {
                    vecIndividual.setObjectAt(i, objLayout);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            aneHelper.setProperty(objLayouts, "individual", vecIndividual);

            for (int i = 0; i < layouts.standard.size(); ++i) {
                layout = layouts.standard.get(i);
                objLayout = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Layout", null);
                aneHelper.setProperty(objLayout, "name", layout.name);
                aneHelper.setProperty(objLayout, "description",layout.description);
                try {
                    vecStandard.setObjectAt(i, objLayout);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            aneHelper.setProperty(objLayouts, "standard", vecStandard);

            return objLayouts;
        }
    }

    private class getColors implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Color>", null);
            ArrayList<Color> itms = libAVANE.getColors();
            Color itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Color", null);
                aneHelper.setProperty(obj, "name", itm.name);
                aneHelper.setProperty(obj, "value", itm.value);
                try {
                    vec.setObjectAt(i, obj);
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
            libAVANE.pauseEncode(aneHelper.getBool(freObjects[0]));
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
            long numParams = aneHelper.getArrayLength(freParams);
            FREObject valueAs;
            String[] params = new String[(int) numParams];

            for (int i = 0; i < numParams; i++) {
                try {
                    valueAs = freParams.getObjectAt(i);
                    params[i] = aneHelper.getString(valueAs);
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
            ret = aneHelper.createFREObject("com.tuarua.ffprobe.Probe", null);

            if (probe != null) {
                FREArray vecVideoStreams;
                FREArray vecAudioStreams;
                FREArray vecSubtitleStreams;
                vecVideoStreams = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffprobe.VideoStream>", null);
                vecAudioStreams = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffprobe.AudioStream>", null);
                vecSubtitleStreams = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffprobe.SubtitleStream>", null);

                VideoStream vs;
                FREObject obj;
                for (int i = 0; i < probe.videoStreams.size(); i++) {
                    vs = probe.videoStreams.get(i);
                    obj = aneHelper.createFREObject("com.tuarua.ffprobe.VideoStream", null);

                    ///////  common /////////////////
                    aneHelper.setProperty(obj, "index", vs.index);
                    aneHelper.setProperty(obj, "codecTag", vs.codecTag);
                    aneHelper.setProperty(obj, "id", vs.id);
                    aneHelper.setProperty(obj, "codecName", vs.codecName);
                    aneHelper.setProperty(obj, "codecLongName", vs.codecLongName);
                    aneHelper.setProperty(obj, "profile", vs.profile);
                    aneHelper.setProperty(obj, "codecType", vs.codecType);
                    aneHelper.setProperty(obj, "codecTimeBase", vs.codecTimeBase);
                    aneHelper.setProperty(obj, "codecTagString", vs.codecTagString);
                    aneHelper.setProperty(obj, "timeBase", vs.timeBase);
                    aneHelper.setProperty(obj, "duration", vs.duration);
                    aneHelper.setProperty(obj, "durationTimestamp", vs.durationTimestamp);
                    aneHelper.setProperty(obj, "realFrameRate", vs.realFrameRate);
                    aneHelper.setProperty(obj, "averageFrameRate", vs.averageFrameRate);
                    aneHelper.setProperty(obj, "startPTS", vs.startPTS);
                    aneHelper.setProperty(obj, "startTime", vs.startTime);
                    aneHelper.setProperty(obj, "bitRate", vs.bitRate);
                    aneHelper.setProperty(obj, "maxBitRate", vs.maxBitRate);
                    aneHelper.setProperty(obj, "bitsPerRawSample", vs.bitsPerRawSample);
                    aneHelper.setProperty(obj, "numFrames", vs.numFrames);
                    FREObject tagsObj;
                    tagsObj = aneHelper.createFREObject("Object", null);

                    if (vs.tags.size() > 0) {
                        for (Map.Entry<String, String> entry : vs.tags.entrySet()) {
                            String key = entry.getKey();
                            String value = entry.getValue();
                            aneHelper.setProperty(tagsObj, key, value);
                        }
                        aneHelper.setProperty(obj, "tags", tagsObj);
                    }

                    /////////////
                    aneHelper.setProperty(obj, "width", vs.width);
                    aneHelper.setProperty(obj, "height", vs.height);
                    aneHelper.setProperty(obj, "codedWidth", vs.codedWidth);
                    aneHelper.setProperty(obj, "codedWidth", vs.codedWidth);
                    aneHelper.setProperty(obj, "hasBframes", vs.hasBframes);
                    aneHelper.setProperty(obj, "level", vs.level);
                    aneHelper.setProperty(obj, "refs", vs.refs);
                    aneHelper.setProperty(obj, "sampleAspectRatio", vs.sampleAspectRatio);
                    aneHelper.setProperty(obj, "displayAspectRatio", vs.displayAspectRatio);
                    aneHelper.setProperty(obj, "pixelFormat", vs.pixelFormat);
                    aneHelper.setProperty(obj, "colorRange", vs.colorRange);
                    aneHelper.setProperty(obj, "colorSpace", vs.colorSpace);
                    aneHelper.setProperty(obj, "colorTransfer", vs.colorTransfer);
                    aneHelper.setProperty(obj, "colorPrimaries", vs.colorPrimaries);
                    aneHelper.setProperty(obj, "chromaLocation", vs.chromaLocation);
                    aneHelper.setProperty(obj, "timecode", vs.timecode);
                    try {
                        vecVideoStreams.setObjectAt(i, obj);
                    } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                        trace("error: " + e.getMessage());
                        e.printStackTrace();
                    }
                }
                aneHelper.setProperty(ret, "videoStreams", vecVideoStreams);


                AudioStream as;
                for (int i = 0; i < probe.audioStreams.size(); i++) {
                    as = probe.audioStreams.get(i);
                    obj = aneHelper.createFREObject("com.tuarua.ffprobe.AudioStream", null);

                    ///////  common /////////////////
                    aneHelper.setProperty(obj, "index", as.index);
                    aneHelper.setProperty(obj, "codecTag", as.codecTag);
                    aneHelper.setProperty(obj, "id", as.id);
                    aneHelper.setProperty(obj, "codecName", as.codecName);
                    aneHelper.setProperty(obj, "codecLongName", as.codecLongName);
                    aneHelper.setProperty(obj, "profile", as.profile);
                    aneHelper.setProperty(obj, "codecType", as.codecType);
                    aneHelper.setProperty(obj, "codecTimeBase", as.codecTimeBase);
                    aneHelper.setProperty(obj, "codecTagString", as.codecTagString);
                    aneHelper.setProperty(obj, "timeBase", as.timeBase);
                    aneHelper.setProperty(obj, "duration", as.duration);
                    aneHelper.setProperty(obj, "durationTimestamp", as.durationTimestamp);
                    aneHelper.setProperty(obj, "realFrameRate", as.realFrameRate);
                    aneHelper.setProperty(obj, "averageFrameRate", as.averageFrameRate);
                    aneHelper.setProperty(obj, "startPTS", as.startPTS);
                    aneHelper.setProperty(obj, "startTime", as.startTime);
                    aneHelper.setProperty(obj, "bitRate", as.bitRate);
                    aneHelper.setProperty(obj, "maxBitRate", as.maxBitRate);
                    aneHelper.setProperty(obj, "bitsPerRawSample", as.bitsPerRawSample);
                    aneHelper.setProperty(obj, "numFrames", as.numFrames);
                    FREObject tagsObj;
                    if (as.tags.size() > 0) {
                        tagsObj = aneHelper.createFREObject("Object", null);
                        for (Map.Entry<String, String> entry : as.tags.entrySet()) {
                            String key = entry.getKey();
                            String value = entry.getValue();
                            aneHelper.setProperty(tagsObj, key, value);
                        }
                        aneHelper.setProperty(obj, "tags", tagsObj);
                    }
                    /////////////

                    aneHelper.setProperty(obj, "sampleFormat", as.sampleFormat);
                    aneHelper.setProperty(obj, "channelLayout", as.channelLayout);
                    aneHelper.setProperty(obj, "sampleRate", as.sampleRate);
                    aneHelper.setProperty(obj, "channels", as.channels);
                    aneHelper.setProperty(obj, "bitsPerSample", as.bitsPerSample);

                    try {
                        vecAudioStreams.setObjectAt(i, obj);
                    } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                        trace("error: " + e.getMessage());
                        e.printStackTrace();
                    }

                }
                aneHelper.setProperty(ret, "audioStreams", vecAudioStreams);

                SubtitleStream ss;
                for (int i = 0; i < probe.subtitleStreams.size(); i++) {
                    ss = probe.subtitleStreams.get(i);
                    obj = aneHelper.createFREObject("com.tuarua.ffprobe.SubtitleStream", null);

                    ///////  common /////////////////
                    aneHelper.setProperty(obj, "index", ss.index);
                    aneHelper.setProperty(obj, "codecTag", ss.codecTag);
                    aneHelper.setProperty(obj, "id", ss.id);
                    aneHelper.setProperty(obj, "codecName", ss.codecName);
                    aneHelper.setProperty(obj, "codecLongName", ss.codecLongName);
                    aneHelper.setProperty(obj, "profile", ss.profile);
                    aneHelper.setProperty(obj, "codecType", ss.codecType);
                    aneHelper.setProperty(obj, "codecTimeBase", ss.codecTimeBase);
                    aneHelper.setProperty(obj, "codecTagString", ss.codecTagString);
                    aneHelper.setProperty(obj, "timeBase", ss.timeBase);
                    aneHelper.setProperty(obj, "duration", ss.duration);
                    aneHelper.setProperty(obj, "durationTimestamp", ss.durationTimestamp);
                    aneHelper.setProperty(obj, "realFrameRate", ss.realFrameRate);
                    aneHelper.setProperty(obj, "averageFrameRate", ss.averageFrameRate);
                    aneHelper.setProperty(obj, "startPTS", ss.startPTS);
                    aneHelper.setProperty(obj, "startTime", ss.startTime);
                    aneHelper.setProperty(obj, "bitRate", ss.bitRate);
                    aneHelper.setProperty(obj, "maxBitRate", ss.maxBitRate);
                    aneHelper.setProperty(obj, "bitsPerRawSample", ss.bitsPerRawSample);
                    aneHelper.setProperty(obj, "numFrames",ss.numFrames);
                    FREObject tagsObj;
                    if (ss.tags.size() > 0) {
                        tagsObj = aneHelper.createFREObject("Object", null);
                        for (Map.Entry<String, String> entry : ss.tags.entrySet()) {
                            String key = entry.getKey();
                            String value = entry.getValue();
                            aneHelper.setProperty(tagsObj, key, value);
                        }
                        aneHelper.setProperty(obj, "tags", tagsObj);
                    }
                    /////////////

                    aneHelper.setProperty(obj, "width", ss.width);
                    aneHelper.setProperty(obj, "height", ss.height);

                    try {
                        vecSubtitleStreams.setObjectAt(i, obj);
                        trace("ss 10");
                    } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                        trace("error: " + e.getMessage());
                        e.printStackTrace();
                    }

                }

                aneHelper.setProperty(ret, "subtitleStreams", vecSubtitleStreams);

                //Format
                FREObject objFormat;
                objFormat = aneHelper.createFREObject("com.tuarua.ffprobe.Format", null);
                aneHelper.setProperty(objFormat, "filename", probe.format.filename);
                aneHelper.setProperty(objFormat, "formatLongName", probe.format.formatLongName);
                aneHelper.setProperty(objFormat, "formatName", probe.format.formatName);
                aneHelper.setProperty(objFormat, "numStreams", probe.format.numStreams);
                aneHelper.setProperty(objFormat, "numPrograms", probe.format.numPrograms);
                aneHelper.setProperty(objFormat, "size", probe.format.size);
                aneHelper.setProperty(objFormat, "bitRate", probe.format.bitRate);
                aneHelper.setProperty(objFormat, "probeScore", probe.format.probeScore);
                aneHelper.setProperty(objFormat, "startTime", probe.format.startTime);
                aneHelper.setProperty(objFormat, "duration", probe.format.duration);

                //convert to helper hashMap to Object //TODO
                FREObject tagsObj;
                if (probe.format.tags.size() > 0) {
                    tagsObj = aneHelper.createFREObject("Object", null);
                    for (Map.Entry<String, String> entry : probe.format.tags.entrySet()) {
                        String key = entry.getKey();
                        String value = entry.getValue();
                        aneHelper.setProperty(tagsObj, key, value);
                    }
                    aneHelper.setProperty(objFormat, "tags", tagsObj);
                }

                aneHelper.setProperty(ret, "format", objFormat);

            }

            return ret;
        }
    }

    private class triggerProbeInfo implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            libAVANE.triggerProbeInfo(aneHelper.getString(freObjects[0]));
            return null;
        }
    }

    private class getSampleFormats implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.SampleFormat>", null);
            ArrayList<SampleFormat> itms = libAVANE.getSampleFormats();
            SampleFormat itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.SampleFormat", null);
                aneHelper.setProperty(obj, "name", itm.name);
                aneHelper.setProperty(obj, "depth", itm.depth);
                try {
                    vec.setObjectAt(i, obj);
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
            return aneHelper.getFREObject(libAVANE.getVersion());
        }
    }

    private class getProtocols implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            Protocols protocols = libAVANE.getProtocols();

            FREObject ret;
            ret = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Protocols", null);

            FREArray vecInputProtocols;
            vecInputProtocols = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Protocol>", null);

            FREArray vecOutputProtocols;
            vecOutputProtocols = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Protocol>", null);

            Protocol itm;
            FREObject obj;
            for (int i = 0; i < protocols.inputs.size(); ++i) {
                itm = protocols.inputs.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Protocol", null);
                aneHelper.setProperty(obj, "name", itm.name);
                try {
                    vecInputProtocols.setObjectAt(i, obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            aneHelper.setProperty(ret, "inputs", vecInputProtocols);


            for (int i = 0; i < protocols.outputs.size(); ++i) {
                itm = protocols.outputs.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Protocol", null);
                aneHelper.setProperty(obj, "name", itm.name);
                try {
                    vecOutputProtocols.setObjectAt(i, obj);
                } catch (FREInvalidObjectException | FREWrongThreadException | FRETypeMismatchException e) {
                    e.printStackTrace();
                }
            }
            aneHelper.setProperty(ret, "outputs", vecOutputProtocols);


            return ret;
        }
    }

    private class getFilters implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Filter>", null);
            ArrayList<Filter> itms = libAVANE.getFilters();
            Filter itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Filter", null);
                aneHelper.setProperty(obj, "hasTimelineSupport", itm.hasTimelineSupport);
                aneHelper.setProperty(obj, "hasSliceThreading", itm.hasSliceThreading);
                aneHelper.setProperty(obj, "hasCommandSupport", itm.hasCommandSupport);
                aneHelper.setProperty(obj, "type", itm.type);
                aneHelper.setProperty(obj, "name", itm.name);
                aneHelper.setProperty(obj, "description", itm.description);
                try {
                    vec.setObjectAt(i, obj);
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
            FREArray vec;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.PixelFormat>", null);
            ArrayList<PixelFormat> itms = libAVANE.getPixelFormats();
            PixelFormat itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.PixelFormat", null);
                aneHelper.setProperty(obj, "isInput", itm.isInput);
                aneHelper.setProperty(obj, "isOutput", itm.isOutput);
                aneHelper.setProperty(obj, "isHardwareAccelerated", itm.isHardwareAccelerated);
                aneHelper.setProperty(obj, "isPalleted", itm.isPalleted);
                aneHelper.setProperty(obj, "isBitStream", itm.isBitStream);
                aneHelper.setProperty(obj, "numComponents", itm.numComponents);
                aneHelper.setProperty(obj, "name", itm.name);
                aneHelper.setProperty(obj, "bitsPerPixel", itm.bitsPerPixel);

                try {
                    vec.setObjectAt(i, obj);
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
            FREArray vec;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.BitStreamFilter>", null);
            ArrayList<BitStreamFilter> itms = libAVANE.getBitStreamFilters();
            BitStreamFilter itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.BitStreamFilter", null);
                aneHelper.setProperty(obj, "name", itm.name);

                try {
                    vec.setObjectAt(i, obj);
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
            FREArray vec;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Decoder>", null);
            ArrayList<Decoder> itms = libAVANE.getDecoders();
            Decoder itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Decoder", null);
                aneHelper.setProperty(obj, "name", itm.name);
                aneHelper.setProperty(obj, "nameLong", itm.nameLong);
                aneHelper.setProperty(obj, "isVideo", itm.isVideo);
                aneHelper.setProperty(obj, "isAudio", itm.isAudio);
                aneHelper.setProperty(obj, "isSubtitles", itm.isSubtitles);
                aneHelper.setProperty(obj, "hasFrameLevelMultiThreading", itm.hasFrameLevelMultiThreading);
                aneHelper.setProperty(obj, "hasSliceLevelMultiThreading", itm.hasSliceLevelMultiThreading);
                aneHelper.setProperty(obj, "isExperimental", itm.isExperimental);
                aneHelper.setProperty(obj, "supportsDrawHorizBand", itm.supportsDrawHorizBand);
                aneHelper.setProperty(obj, "supportsDirectRendering", itm.supportsDirectRendering);
                try {
                    vec.setObjectAt(i, obj);
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
            FREArray vec;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Encoder>", null);
            ArrayList<Encoder> itms = libAVANE.getEncoders();
            Encoder itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Encoder", null);
                aneHelper.setProperty(obj, "name", itm.name);
                aneHelper.setProperty(obj, "nameLong", itm.nameLong);
                aneHelper.setProperty(obj, "isVideo", itm.isVideo);
                aneHelper.setProperty(obj, "isAudio", itm.isAudio);
                aneHelper.setProperty(obj, "isSubtitles", itm.isSubtitles);
                aneHelper.setProperty(obj, "hasFrameLevelMultiThreading", itm.hasFrameLevelMultiThreading);
                aneHelper.setProperty(obj, "hasSliceLevelMultiThreading", itm.hasSliceLevelMultiThreading);
                aneHelper.setProperty(obj, "isExperimental", itm.isExperimental);
                aneHelper.setProperty(obj, "supportsDrawHorizBand", itm.supportsDrawHorizBand);
                aneHelper.setProperty(obj, "supportsDirectRendering", itm.supportsDirectRendering);
                try {
                    vec.setObjectAt(i, obj);
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
            FREArray vec;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.HardwareAcceleration>", null);
            ArrayList<HardwareAcceleration> itms = libAVANE.getHardwareAccelerations();
            HardwareAcceleration itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Encoder", null);
                aneHelper.setProperty(obj, "name", itm.name);
                try {
                    vec.setObjectAt(i, obj);
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
            return aneHelper.getFREObject(libAVANE.getLicense());
        }
    }

    private class getCodecs implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREArray vec;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Codec>", null);
            ArrayList<Codec> itms = libAVANE.getCodecs();
            Codec itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Codec", null);
                aneHelper.setProperty(obj, "name", itm.name);
                aneHelper.setProperty(obj, "nameLong", itm.nameLong);
                aneHelper.setProperty(obj, "hasDecoder", itm.hasDecoder);
                aneHelper.setProperty(obj, "hasEncoder", itm.hasEncoder);
                aneHelper.setProperty(obj, "isVideo", itm.isVideo);
                aneHelper.setProperty(obj, "isAudio", itm.isAudio);
                aneHelper.setProperty(obj, "isSubtitles", itm.isSubtitles);
                aneHelper.setProperty(obj, "isLossy", itm.isLossy);
                aneHelper.setProperty(obj, "isLossless", itm.isLossless);
                aneHelper.setProperty(obj, "isIntraFrameOnly", itm.isIntraFrameOnly);

                try {
                    vec.setObjectAt(i, obj);
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
            FREArray vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Device>", null);
            ArrayList<Device> itms = libAVANE.getDevices();
            Device itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.Device", null);
                aneHelper.setProperty(obj, "name", itm.name);
                aneHelper.setProperty(obj, "nameLong", itm.nameLong);
                aneHelper.setProperty(obj, "muxing", itm.muxing);
                aneHelper.setProperty(obj, "demuxing", itm.demuxing);

                try {
                    vec.setObjectAt(i, obj);
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
            FREArray vec;
            vec = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.AvailableFormat>", null);
            ArrayList<AvailableFormat> itms = libAVANE.getAvailableFormats();
            AvailableFormat itm;
            FREObject obj;
            for (int i = 0; i < itms.size(); ++i) {
                itm = itms.get(i);
                obj = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.AvailableFormat", null);
                aneHelper.setProperty(obj, "name", itm.name);
                aneHelper.setProperty(obj, "nameLong", itm.nameLong);
                aneHelper.setProperty(obj, "muxing", itm.muxing);
                aneHelper.setProperty(obj, "demuxing", itm.demuxing);

                try {
                    vec.setObjectAt(i, obj);
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
            return aneHelper.getFREObject(libAVANE.getBuildConfiguration());
        }
    }


    private void trace(String msg) {
        if (logLevel > LogLevel.QUIET) {
            Log.i("com.tuarua.AVANE", String.valueOf(msg));
            dispatchStatusEventAsync(msg, "TRACE");
        }
    }

    private void trace(int msg) {
        if (logLevel > LogLevel.QUIET) {
            Log.i("com.tuarua.AVANE", String.valueOf(msg));
            dispatchStatusEventAsync(String.valueOf(msg), "TRACE");
        }
    }

    private void trace(boolean msg) {
        if (logLevel > LogLevel.QUIET) {
            Log.i("com.tuarua.AVANE", String.valueOf(msg));
            dispatchStatusEventAsync(String.valueOf(msg), "TRACE");
        }
    }

    @Override
    public void dispose() {

    }

    private class getCaptureDevices implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.CaptureDevice>", null);
        }
    }
}
