package {
import com.tuarua.ffmpeg.AVFoundationOptions;
import com.tuarua.ffmpeg.InputOptions;
import com.tuarua.ffmpeg.InputStream;
import com.tuarua.ffmpeg.OutputOptions;
import com.tuarua.ffmpeg.OutputVideoStream;
import com.tuarua.ffmpeg.X264Options;
import com.tuarua.ffmpeg.constants.X264Preset;
import com.tuarua.ffmpeg.gets.CaptureDevice;

import flash.filesystem.File;
	
	import com.tuarua.AVANE;
	import com.tuarua.ffmpeg.constants.LogLevel;
	import com.tuarua.ffmpeg.events.FFmpegEvent;
	import com.tuarua.ffmpeg.gets.AvailableFormat;
	import com.tuarua.ffmpeg.gets.BitStreamFilter;
	import com.tuarua.ffmpeg.gets.Codec;
	import com.tuarua.ffmpeg.gets.Color;
	import com.tuarua.ffmpeg.gets.Decoder;
	import com.tuarua.ffmpeg.gets.Device;
	import com.tuarua.ffmpeg.gets.Encoder;
	import com.tuarua.ffmpeg.gets.Filter;
	import com.tuarua.ffmpeg.gets.HardwareAcceleration;
	import com.tuarua.ffmpeg.gets.PixelFormat;
	import com.tuarua.ffmpeg.gets.Protocols;
	import com.tuarua.ffmpeg.gets.SampleFormat;
	import com.tuarua.ffprobe.Probe;
	import com.tuarua.ffprobe.events.ProbeEvent;

import flash.net.URLRequest;

import flash.net.navigateToURL;

import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	import views.loader.CircularLoader;
	import utils.*;

	public class StarlingRoot extends Sprite {
		private var encodeBtn:Sprite;
        private var cameraBtn:Sprite;
		private var cancelBtn:Sprite;
		private var fontSize:int = 36;
		private var versionTxt:TextField;
		private var urlTxt:TextField;
		private var progressTxt:TextField;
		private var avANE:AVANE = new AVANE();
		private var circularLoader:CircularLoader = new CircularLoader();
		private var _totalTime:Number;
		public function StarlingRoot() {
			super();
			//this.scaleX = 0.5;
			//this.scaleY = 0.5;
		}
		public function start():void {

			trace(File.documentsDirectory.nativePath);

			avANE.setLogLevel(LogLevel.INFO);
			avANE.addEventListener(ProbeEvent.ON_PROBE_INFO,onProbeInfo);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_START,onEncodeStart);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_PROGRESS,onEncodeProgress);
			
			/*
			var codecs:Vector.<Codec> = avANE.getCodecs();
			var devices:Vector.<Device> = avANE.getDevices();
			var availableFormat:Vector.<AvailableFormat> = avANE.getAvailableFormats();
			*/




			var cap:Vector.<CaptureDevice> = avANE.getCaptureDevices();
            for each (var device1:CaptureDevice in cap) {
				trace("capture device:",device1.name, device1.format,device1.isVideo,device1.index);
            }

			var encoders:Vector.<Encoder> = avANE.getEncoders();
            for each (var encoder:Encoder in encoders) {
				trace("encoder:",encoder.name, encoder.nameLong);
            }

			trace("-------");

			trace(avANE.isSupported());
			trace(avANE.getVersion());
			trace(avANE.getLicense());
			
			encodeBtn = createButton("Encode");
			encodeBtn.addEventListener(TouchEvent.TOUCH,onEncodeTouch);

            cameraBtn = createButton("Rec. Camera");
            cameraBtn.addEventListener(TouchEvent.TOUCH,onCameraTouch);
			
			cancelBtn = createButton("Cancel");
			cancelBtn.addEventListener(TouchEvent.TOUCH,onCancelTouch);
			
			var tfl:TextFormat = new TextFormat("Roboto-Medium", fontSize, 0xFFFFFF);
			tfl.horizontalAlign = Align.LEFT;
			tfl.verticalAlign = Align.TOP;
			
			versionTxt = new TextField(800, 400, avANE.getVersion());
			versionTxt.format = tfl;
			versionTxt.x = 50;
			versionTxt.y = 50;
			addChild(versionTxt);
			
			
			urlTxt = new TextField(800, 100, "http://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4");
			urlTxt.format = tfl;
			urlTxt.x = 50;
			urlTxt.y = 500;
			addChild(urlTxt);

            cameraBtn.x = cancelBtn.x = encodeBtn.x = (Starling.current.viewPort.width-320)/2;
			cancelBtn.y = encodeBtn.y = 700;
            cameraBtn.y = encodeBtn.y + 200;
			
			cancelBtn.visible = false;
			
			addChild(encodeBtn);
            addChild(cameraBtn);
			addChild(cancelBtn);
			
			circularLoader.x = (Starling.current.viewPort.width-320)/2;
			circularLoader.y = 1200;
			circularLoader.visible = false;
			addChild(circularLoader);
			
			progressTxt = new TextField(800, 400, "");
			progressTxt.format = tfl;
			progressTxt.x = 50;
			progressTxt.y = 1400;
			addChild(progressTxt);	
			
		}
		
		protected function onProbeInfo(event:ProbeEvent):void {
			var probe:Probe = event.params.data as Probe;
			_totalTime = probe.format.duration;
			avANE.encode("-i http://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4 -c:v h264_videotoolbox -b:v 2048k -c:a copy -profile:v high -y " + File.documentsDirectory.nativePath + "/AVANEtest.mp4");
		}
		// -q 10 -qscale:v 10
		protected function onEncodeProgress(event:FFmpegEvent):void {
			progressTxt.text = "time:" + TimeUtils.secsToTimeCode((event.params.secs) + (event.params.us/100)) + " / "+TimeUtils.secsToTimeCode(_totalTime);
			progressTxt.text += "\nframe:" + event.params.frame.toString();
			progressTxt.text += "\nsize:" + TextUtils.bytesToString(event.params.size*1024);
			progressTxt.text += "\nbitrate:" + event.params.bitrate.toFixed(2)+" Kbps";
			progressTxt.text += "\nspeed:" + event.params.speed.toFixed(2)+"x";
			progressTxt.text += "\nfps:" + event.params.fps.toFixed(2);
			circularLoader.update(((event.params.secs) + (event.params.us/100)) / _totalTime);
			
		}
		
		protected function onEncodeFinish(event:FFmpegEvent):void{
			trace(event);
			circularLoader.update(1.0);
			encodeBtn.visible = true;
			cancelBtn.visible = false;
            cameraBtn.visible = true;

			var encoded:File = new File(File.documentsDirectory.nativePath + "/AVANEtest.mp4");
			trace("encoded.nativePath",encoded.nativePath);
			trace("encoded.exists",encoded.exists);

		}
		
		protected function onEncodeStart(event:FFmpegEvent):void {
			trace(event);
			circularLoader.visible = true;
		}

        private function onCameraTouch(event:TouchEvent):void {
            event.stopPropagation();
            var touch:Touch = event.getTouch(cameraBtn, TouchPhase.ENDED);
            if(touch && touch.phase == TouchPhase.ENDED)  {
                cancelBtn.visible = true;
                encodeBtn.visible = false;
                cameraBtn.visible = false;

                var inputOptions:InputOptions = new InputOptions();

				inputOptions.format = "avfoundation";
				inputOptions.uri = "0:none";


				var avOptions:AVFoundationOptions = new AVFoundationOptions();
				avOptions.frameRate = 30;
				avOptions.videoSize = "1280x720";
				inputOptions.addExtraOptions(avOptions);


				InputStream.clear();
				InputStream.addInput(inputOptions);


                var videoStream:OutputVideoStream = new OutputVideoStream();
				videoStream.bitrate = 3000 * 1024;
                videoStream.codec = "h264_videotoolbox";

                OutputOptions.addVideoStream(videoStream);

                OutputOptions.frameRate = 60;
                OutputOptions.bufferSize = 3000 * 1024;
                OutputOptions.maxRate = 3000 * 1024;


                OutputOptions.uri = File.documentsDirectory.nativePath + "/AVANEcameraTest.mp4";

                avANE.encode();

            }
        }

		private function onEncodeTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(encodeBtn, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)  {
				cancelBtn.visible = true;
				encodeBtn.visible = false;
                cameraBtn.visible = false;
				avANE.getProbeInfo("http://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4");
			}
		}
		
		private function onCancelTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(cancelBtn, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)  {
				encodeBtn.visible = true;
				cameraBtn.visible = true;
				cancelBtn.visible = false;
				avANE.cancelEncode();
			}
		}
		
		private function createButton(lbl:String):Sprite {
			var spr:Sprite = new Sprite();
			var bg:Quad = new Quad(320,100,0xFFFFFF);
			
			var tf:TextFormat = new TextFormat("Roboto-Medium", fontSize, 0x000000);
			tf.horizontalAlign = Align.CENTER;
			tf.verticalAlign = Align.TOP;
			
			var lblTxt:TextField = new TextField(320, 80, lbl);
			lblTxt.format = tf;
			lblTxt.y = 32;
			
			spr.addChild(bg);
			spr.addChild(lblTxt);
			return spr;
		}
	}
}