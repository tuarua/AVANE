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
				
				//InputStream.clear();
				//OutputOptions.clear();
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
				
				//https://github.com/rdp/screen-capture-recorder-to-video-windows-free
				//ffmpeg -f dshow -i video="screen-capture-recorder" -r 60 -t 10 D:\\screen-capture.mp4
				
				
				var inputOptions:InputOptions = new InputOptions();
				inputOptions.format = "dshow";
				
				inputOptions.uri = "video=" + deviceList[deviceDrop.selected].value;
				
				InputStream.clear();
				InputStream.addInput(inputOptions);
				
				var videoStream:OutputVideoStream = new OutputVideoStream();
				videoStream.crf = 0;
				videoStream.codec = "libx264";
				videoStream.pixelFormat = "yuv420p";
				OutputOptions.addVideoStream(videoStream);
				
				OutputOptions.preset = X264Preset.ULTRA_FAST;
				OutputOptions.addVideoFilter("format=yuv420p");
				OutputOptions.duration = 10;
				OutputOptions.frameRate = 60;
				OutputOptions.bufferSize = 3000 * 1024;
				OutputOptions.maxRate = 3000 * 1024;
				
				OutputOptions.uri = File.desktopDirectory.resolvePath("screen-capture.mp4").nativePath;
				
				
				
				avANE.encode();
				
				//
				//avANE.encodeClassic("-f dshow -i video=\"screen-capture-recorder\" -r 60 -c:v libx264 -maxrate 3000k -bufsize 3000k -crf 0 -pix_fmt yuv420p -preset ultrafast -t 10 -y D:\screen-capture-classic.mp4");
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