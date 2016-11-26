package views {
	
	import com.tuarua.AVANE;
	import com.tuarua.BuildMode;
	import com.tuarua.ffmpeg.InputOptions;
	import com.tuarua.ffmpeg.InputStream;
	import com.tuarua.ffmpeg.Logger;
	import com.tuarua.ffmpeg.OutputOptions;
	import com.tuarua.ffmpeg.OutputVideoStream;
	import com.tuarua.ffmpeg.X264Options;
	import com.tuarua.ffmpeg.constants.LogLevel;
	import com.tuarua.ffmpeg.constants.X264Preset;
	import com.tuarua.ffmpeg.constants.X264Profile;
	import com.tuarua.ffmpeg.events.FFmpegEvent;
	import com.tuarua.ffmpeg.gets.CaptureDevice;
	
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import views.forms.DropDown;
	import com.tuarua.ffmpeg.AVFoundationOptions;

	public class DesktopCapture extends Sprite {
		private var captureButton:SimpleButton = new SimpleButton("Start Capture",120);
		private var cancelButton:SimpleButton = new SimpleButton("Stop Capture",120);
		private var avANE:AVANE;
		private var deviceDrop:DropDown;
		private var deviceList:Vector.<Object> = new Vector.<Object>;
		public function DesktopCapture(_avANE:AVANE) {
			super();
			avANE = _avANE;
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
			
			cancelButton.x = captureButton.x = 450;
			cancelButton.y = captureButton.y = 38;
			cancelButton.addEventListener(TouchEvent.TOUCH,onCancel);
			cancelButton.visible = false;
			
			var devices:Vector.<CaptureDevice> = avANE.getCaptureDevices();
			
			if(devices.length > 0){
				for each(var d:CaptureDevice in devices){
					if(d.isVideo)
						deviceList.push({value:d.name,label:d.name});
				}
				deviceDrop = new DropDown(300,deviceList);
				deviceDrop.x = 100;
				deviceDrop.y = captureButton.y + 8;
				addChild(deviceDrop);
			}
			
			captureButton.addEventListener(TouchEvent.TOUCH,onCaptureTouch);
			addChild(captureButton);
			addChild(cancelButton);
			
			
		}

		private function onCancel(event:TouchEvent):void {
			var touch:Touch = event.getTouch(cancelButton);
			if(touch != null && touch.phase == TouchPhase.ENDED){
				avANE.cancelEncode();
				
				cancelButton.visible = false;
				captureButton.visible = true;

			}	
		}
		private function onCaptureTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(captureButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED){
				
				cancelButton.visible = true;
				captureButton.visible = false;
				
				avANE.setLogLevel(BuildMode.isDebugBuild() ? LogLevel.INFO :  LogLevel.QUIET); 
				
				Logger.enableLogToTextField = false;
				Logger.enableLogToTrace = BuildMode.isDebugBuild();
				Logger.enableLogToFile = false;
				
				var inputOptions:InputOptions = new InputOptions();

                if(Capabilities.os.toLowerCase().lastIndexOf("windows") > -1) {
                    inputOptions.format = "dshow";
                    inputOptions.uri = "video=" + deviceList[deviceDrop.selected].value;
                    InputStream.clear();
                    InputStream.addInput(inputOptions);

				} else {
                    inputOptions.format = "avfoundation";
                    inputOptions.uri = deviceList[deviceDrop.selected].value + ":none";

					var avOptions:AVFoundationOptions = new AVFoundationOptions();
					avOptions.frameRate = 60;
					avOptions.captureCursor = true;
					avOptions.pixelFormat = "uyvy422";
					inputOptions.addExtraOptions(avOptions);
                    InputStream.clear();
                    InputStream.addInput(inputOptions);
				}


                var videoStream:OutputVideoStream = new OutputVideoStream();
                videoStream.crf = 0;
                videoStream.codec = "libx264";
                if(Capabilities.os.toLowerCase().lastIndexOf("windows") > -1)
					videoStream.pixelFormat = "yuv420p";

                var x264Options:X264Options = new X264Options();
                x264Options.preset = X264Preset.ULTRA_FAST;
                videoStream.encoderOptions = x264Options;

				OutputOptions.addVideoStream(videoStream);

                if(Capabilities.os.toLowerCase().lastIndexOf("windows") > -1)
					OutputOptions.addVideoFilter("format=yuv420p");
				OutputOptions.frameRate = 60;
				OutputOptions.bufferSize = 3000 * 1024;
				OutputOptions.maxRate = 3000 * 1024;


				OutputOptions.uri = File.desktopDirectory.resolvePath("screen-capture.mp4").nativePath;

				avANE.encode();

			}
		}
		protected function onEncodeFinish(event:FFmpegEvent):void {
			trace(event);
			cancelButton.visible = false;
			captureButton.visible = true;
			InputStream.clear();
			OutputOptions.clear();
			Logger.finish();
		}
		
		public function resume():void {
			this.visible = true;
			if(avANE){
				avANE.addEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
				avANE.cancelEncode();
			}
		}
		
		public function suspend():void {
			if(avANE){
				avANE.removeEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
			}
			this.visible = false;	
		}

	}
}