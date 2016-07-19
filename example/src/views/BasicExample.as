package views {
	import com.tuarua.AVANE;
	import com.tuarua.BuildMode;
	import com.tuarua.ffmpeg.GlobalOptions;
	import com.tuarua.ffmpeg.InputOptions;
	import com.tuarua.ffmpeg.InputStream;
	import com.tuarua.ffmpeg.Logger;
	import com.tuarua.ffmpeg.OutputAudioStream;
	import com.tuarua.ffmpeg.OutputOptions;
	import com.tuarua.ffmpeg.OutputVideoStream;
	import com.tuarua.ffmpeg.constants.LogLevel;
	import com.tuarua.ffmpeg.events.FFmpegEvent;
	
	import flash.filesystem.File;
	import flash.text.TextField;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import utils.TextUtils;
	import utils.TimeUtils;
	
	public class BasicExample extends Sprite {
		private var encodeButton:SimpleButton = new SimpleButton("Encode");
		private var encodeClassicButton:SimpleButton = new SimpleButton("Encode Classic",200);
		private var avANE:AVANE;
		private var loggerTextField:TextField;
		public function BasicExample(_avANE:AVANE) {
			super();
			avANE = _avANE;
			
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_PROGRESS,onProgress);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_START,onEncodeStart);
			
			loggerTextField = Logger.textField;
			loggerTextField.y = 300;
			loggerTextField.background = false;
			Starling.current.nativeOverlay.addChild(loggerTextField);
			
			encodeButton.x = 450;
			encodeButton.y = 38;
			encodeButton.addEventListener(TouchEvent.TOUCH,onEncodeTouch);
			addChild(encodeButton);
			
			encodeClassicButton.x = 600;
			encodeClassicButton.y = 38;
			encodeClassicButton.addEventListener(TouchEvent.TOUCH,onEncodeClassicTouch);
			addChild(encodeClassicButton);
			
		}
		private function onEncodeTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(encodeButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED){
				avANE.setLogLevel(BuildMode.isDebugBuild() ? LogLevel.VERBOSE :  LogLevel.QUIET); 
				Logger.enableLogToTextField = true; //it is not advisable to set to true if using LogLevel.DEBUG or LogLevel.TRACE, the flash textField can't handle it
				Logger.enableLogToTrace = true;
				Logger.enableLogToFile = false;
				
				var inputOptions:InputOptions = new InputOptions();
				inputOptions.uri = "https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4";
				inputOptions.duration = 10;
				InputStream.clear();
				InputStream.addInput(inputOptions);
				
				//video
				var videoStream:OutputVideoStream = new OutputVideoStream();
				videoStream.codec = "libx264";
				
				OutputOptions.addVideoStream(videoStream);
				
				//audio
				var audioStream:OutputAudioStream = new OutputAudioStream();
				audioStream.codec = "aac";
				OutputOptions.addAudioStream(audioStream);
				
				OutputOptions.uri = File.desktopDirectory.resolvePath("avane-encode.mp4").nativePath;
				avANE.encode();
			}	
		}
		
		private function onEncodeClassicTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(encodeClassicButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED){
				//this is the equivalent of the above in 'classic' ffmpeg style
				avANE.encode("-i https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4 -c:v libx264 -c:a aac -y \""+File.desktopDirectory.resolvePath("avane-encode-classic.mp4").nativePath+"\"");
			}
		}
		
		protected function onEncodeFinish(event:FFmpegEvent):void {
			trace(event);
			InputStream.clear();
			OutputOptions.clear();
			Logger.finish();
		}
		protected function onEncodeStart(event:FFmpegEvent):void {
			trace(event);
		}
		public function onProgress(event:FFmpegEvent):void {
			
			trace("time:",TimeUtils.secsToTimeCode((event.params.secs) + (event.params.us/100)));
			trace("frame:",event.params.frame.toString());
			trace("size:",TextUtils.bytesToString(event.params.size*1024));
			trace("bitrate:",event.params.bitrate.toFixed(2)+" Kbps");
			trace("speed:",event.params.speed.toFixed(2)+"x");
			trace("fps:",event.params.fps.toFixed(2));
			trace();
			
		}
		public function resume():void {
			this.visible = true;
			if(avANE){
				avANE.addEventListener(FFmpegEvent.ON_ENCODE_PROGRESS,onProgress);
				avANE.addEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
				avANE.addEventListener(FFmpegEvent.ON_ENCODE_START,onEncodeStart);
				avANE.cancelEncode();
			}
			if(loggerTextField)
				Starling.current.nativeOverlay.addChild(loggerTextField);
		}
		public function suspend():void {
			if(avANE){
				avANE.removeEventListener(FFmpegEvent.ON_ENCODE_PROGRESS,onProgress);
				avANE.removeEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
				avANE.removeEventListener(FFmpegEvent.ON_ENCODE_START,onEncodeStart);
			}
			if(loggerTextField){
				if(Starling.current.nativeOverlay.contains(loggerTextField))
					Starling.current.nativeOverlay.removeChild(loggerTextField);
				loggerTextField.text = "";
			}
			this.visible = false;
		}
	}
}