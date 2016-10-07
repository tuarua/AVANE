package com.tuarua.avane.android.libavaneexample;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.tuarua.avane.android.LibAVANE;
import com.tuarua.avane.android.Progress;
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
import com.tuarua.avane.android.gets.Layouts;
import com.tuarua.avane.android.gets.PixelFormat;
import com.tuarua.avane.android.gets.Protocols;
import com.tuarua.avane.android.gets.SampleFormat;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {


    private LibAVANE libAVANE;
    private String appDirectory;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        libAVANE = LibAVANE.getInstance();
        libAVANE.setLogLevel(16);

        TextView tv = (TextView) findViewById(R.id.textView);
        tv.setText(libAVANE.getVersion());

        Log.i("build config",libAVANE.getBuildConfiguration());

        PackageManager m = getPackageManager();
        appDirectory = getPackageName();
        PackageInfo p = null;
        try {
            p = m.getPackageInfo(appDirectory, 0);
            appDirectory = p.applicationInfo.dataDir; // /data/user/0/com.tuarua.avane.android.libavaneexample
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }


        Button btn = (Button) findViewById(R.id.button);
        btn.setOnClickListener(
                new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Log.i("button clicked","click");
                        doEncode();
                    }
                });


        libAVANE.eventDispatcher.addEventListener(Event.TRACE, new IEventHandler(){
            @Override
            public void callback(Event event) {
                String msg = (String) event.getParams();
                Log.i("MA trace",msg);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.INFO, new IEventHandler(){
            @Override
            public void callback(Event event) {
                String msg = (String) event.getParams();
                Log.i("MA info",msg);
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_START, new IEventHandler(){
            @Override
            public void callback(Event event) {
                String msg = (String) event.getParams();
                Log.i("MA","encode start");
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_FINISH, new IEventHandler(){
            @Override
            public void callback(Event event) {
                String msg = (String) event.getParams();
                Log.i("MA","encode finish");
            }
        });
        libAVANE.eventDispatcher.addEventListener(Event.ON_ENCODE_PROGRESS, new IEventHandler() {
            @Override
            public void callback(Event event) {
                Progress progress = (Progress) event.getParams();
                Log.i("MA fps", String.valueOf(progress.fps));
                Log.i("MA bitrate", String.valueOf(progress.bitrate));
                Log.i("MA size", String.valueOf(progress.size));
                Log.i("MA frame", String.valueOf(progress.frame));
                Log.i("MA speed", String.valueOf(progress.speed));
            }
        });


    }

    private void doEncode(){
        String[] params = {"-i",
                "http://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4",
                "-c:v","libx264","-c:a","copy","-preset","ultrafast","-y", appDirectory + "/files/avane-encode-classic.mp4"};

        libAVANE.encode(params);
    }
    private void getAvailableFormats(){
        /*
        ArrayList<Color> clrs = libAVANE.getColors();
        Log.i("num colors",String.valueOf(clrs.size()));
        */

        /*
        ArrayList<PixelFormat> fltrs = libAVANE.getPixelFormats();
        Log.i("num flters",String.valueOf(fltrs.size()));
        */

        //Layouts layouts = libAVANE.getLayouts();
        //Protocols protocols = libAVANE.getProtocols();
        //Log.i("num inputs",String.valueOf(protocols.inputs.size()));
        //Log.i("num outputs",String.valueOf(protocols.outputs.size()));

        /*
        ArrayList<BitStreamFilter> bitStreamFilters = libAVANE.getBitStreamFilters();
        Log.i("num bsfs",String.valueOf(bitStreamFilters.size()));
        */

        /*
        ArrayList<Codec> codecs = libAVANE.getCodecs();
        Log.i("num codecs",String.valueOf(codecs.size()));
        */

        /*
        ArrayList<Decoder> decoders = libAVANE.getDecoders();
        Log.i("num decoders",String.valueOf(decoders.size()));
        */

        /*
        ArrayList<Encoder> encoders = libAVANE.getEncoders();
        Log.i("num encoders",String.valueOf(encoders.size()));
        */
        /*
        ArrayList<HardwareAcceleration> hwAcc = libAVANE.getHardwareAccelerations();
        Log.i("num hw accels",String.valueOf(hwAcc.size()));
        */
        /*
        ArrayList<Device> devices = libAVANE.getDevices();
        Log.i("num devices",String.valueOf(devices.size()));
        */

        ArrayList<AvailableFormat> formats = libAVANE.getAvailableFormats();
        for (AvailableFormat format : formats) {
            Log.i("format: ",format.nameLong);
        }
        Log.i("num formats",String.valueOf(formats.size()));



        /*
        ArrayList<SampleFormat> formats = libAVANE.getSampleFormats();
        for (SampleFormat format : formats) {
            Log.i("format: ",format.name);
        }
        */
        Log.i("num sample formats",String.valueOf(formats.size()));
    }

}
