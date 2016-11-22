package views {
	import com.tuarua.AVANE;
	import com.tuarua.BuildMode;
	import com.tuarua.ffmpeg.Attachment;
	import com.tuarua.ffmpeg.GlobalOptions;
	import com.tuarua.ffmpeg.InputOptions;
	import com.tuarua.ffmpeg.InputStream;
	import com.tuarua.ffmpeg.Logger;
	import com.tuarua.ffmpeg.MetaData;
	import com.tuarua.ffmpeg.OutputAudioStream;
	import com.tuarua.ffmpeg.OutputOptions;
	import com.tuarua.ffmpeg.OutputVideoStream;
	import com.tuarua.ffmpeg.Streamer;
	import com.tuarua.ffmpeg.X264Options;
	import com.tuarua.ffmpeg.constants.LogLevel;
	import com.tuarua.ffmpeg.constants.X264Preset;
	import com.tuarua.ffmpeg.constants.X264Profile;
	import com.tuarua.ffmpeg.events.FFmpegEvent;
	import com.tuarua.ffmpeg.events.StreamProviderEvent;
	import com.tuarua.ffmpeg.gets.CaptureDevice;
	import com.tuarua.ffmpeg.gets.HardwareAcceleration;
	import com.tuarua.ffprobe.AudioStream;
	import com.tuarua.ffprobe.Probe;
	import com.tuarua.ffprobe.events.ProbeEvent;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import events.InteractionEvent;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	import views.forms.DropDown;
	import views.loader.CircularLoader;
	import views.video.controls.ControlsContainer;

	public class UniversalPlayer extends Sprite {
		private var avANE:AVANE;
		private var urlDrop:DropDown;
		private var urlList:Vector.<Object> = new Vector.<Object>;
		private var playButton:SimpleButton = new SimpleButton("Play");
		private var streamer:Streamer;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var vidClient:Object;
		private var uri:String;
		private var isLive:Boolean = false;
		private var videoImage:Image;
		private var videoTexture:Texture;
		private var loading:LoadingIcon = new LoadingIcon();
		private var soundTransform:SoundTransform = new SoundTransform();
		private var circularLoader:CircularLoader;

		private var hwAccels:Vector.<HardwareAcceleration>;
		
		public var controls:ControlsContainer = new ControlsContainer();
		private var controlsTimer:Timer = new Timer(5000);
		private var videoDuration:Number = 0;
		private var isSeeking:Boolean = false;
		private var nFauxOffset:Number = 0;
		private var seekAfterEncodeFinish:Boolean = false;
		private var playAfterEncodeFinish:Boolean = false;
		
		private var startTime:Number;
		private var durTimer:Timer;
		
		public function UniversalPlayer(_avANE:AVANE) {
			super();
			
			controls.addEventListener(InteractionEvent.ON_CONTROLS_PLAY,onPlayClick);
			controls.addEventListener(InteractionEvent.ON_CONTROLS_PAUSE,onPauseClick);
			controls.addEventListener(InteractionEvent.ON_CONTROLS_SEEK,onSeek);
			controls.addEventListener(InteractionEvent.ON_CONTROLS_MUTE,onMute);
			controls.addEventListener(InteractionEvent.ON_CONTROLS_SETVOLUME,onSetVolume);
			
			avANE = _avANE;
			
			hwAccels = avANE.getHardwareAccelerations();
			
			avANE.addEventListener(ProbeEvent.ON_PROBE_INFO,onProbeInfo);
			avANE.addEventListener(ProbeEvent.NO_PROBE_INFO,onNoProbeInfo);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_ERROR,onEncodeError);
			
			streamer = new Streamer("127.0.0.1",1234);
			streamer.addEventListener(StreamProviderEvent.ON_STREAM_DATA,onStreamData);
			streamer.addEventListener(StreamProviderEvent.ON_STREAM_CLOSE,onStreamClose);
			
			
			urlList.push({value:"{\"uri\":\"https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4\",\"live\":false}",label:"MP4 H.264   -   https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4"});
			urlList.push({value:"{\"uri\":\"http://video.h265files.com/TearsOfSteel_720p_h265.mkv\",\"live\":false}",label:"MKV HEVC   -   http://video.h265files.com/TearsOfSteel_720p_h265.mkv"});
			urlList.push({value:"{\"uri\":\"http://yt-dash-mse-test.commondatastorage.googleapis.com/media/feelings_vp9-20130806-247.webm\",\"live\":false}",label:"WEBM VP9   -   http://yt-dash-mse-test.commondatastorage.googleapis.com/media/feelings_vp9-20130806-247.webm"});
			urlList.push({value:"{\"uri\":\"http://s1.demo-world.eu/hd_trailers.php?file=samsung_canadian_scenery-DWEU.mkv\",\"live\":false}",label:"MKV H.264   -   http://s1.demo-world.eu/hd_trailers.php?file=samsung_canadian_scenery-DWEU.mkv"});
			urlList.push({value:"{\"uri\":\"http://nasatv-lh.akamaihd.net/i/NASA_101@319270/index_1000_av-p.m3u8?sd=10&rebase=on\",\"live\":true}",label:"NASA TV HLS   -   http://nasatv-lh.akamaihd.net/i/NASA_101@319270/index_1000_av-p.m3u8?sd=10&rebase=on"});
			
			playButton.x = 1050;
			playButton.y = 38;
			playButton.addEventListener(TouchEvent.TOUCH,onPlayTouch);
			
			urlDrop = new DropDown(900,urlList);
			urlDrop.x = 100;
			urlDrop.y = playButton.y + 8;
			
			loading.x = 640;
			loading.y = 440;
			
			addChild(urlDrop);
			addChild(playButton);
			
			
			addChild(loading);
			
		}
		
		private function onPlayClick(event:InteractionEvent):void {
			ns.resume();
			avANE.pauseEncode(false);
		}
		private function onPauseClick(event:InteractionEvent):void {
			ns.pause();
			avANE.pauseEncode(true);
		}
		
		private function onSeek(event:InteractionEvent):void {
			var newTime:Number = event.params.time;
			isSeeking = true;
			showLoading();
			nFauxOffset = newTime;
			streamer.suspend();
			ns.seek(0);
			ns.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
			ns.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			if(streamer.connected)
				avANE.cancelEncode();
			
			InputStream.options[0].startTime = newTime;
			seekAfterEncodeFinish = true;
			
		}
		
		private function onMute(event:InteractionEvent):void {
			if(controls.isMuted){
				soundTransform.volume = 0;
				ns.soundTransform = soundTransform;
			}else{
				soundTransform.volume = controls.volume;
				ns.soundTransform = soundTransform;
			}
		}
		
		private function onSetVolume(event:InteractionEvent):void {
			soundTransform.volume = controls.volume;
			ns.soundTransform = soundTransform;
		}
		
		private function startControlsTimer():void {
			controlsTimer.addEventListener(TimerEvent.TIMER,onControlsTimer);
			controlsTimer.start();
		}
		private function stopControlsTimer():void {
			controlsTimer.reset();
			controlsTimer.stop();
			controlsTimer.removeEventListener(TimerEvent.TIMER,onControlsTimer);
			Mouse.show();
		}
		
		private function stopDurationTimer():void {
			if(durTimer){
				durTimer.reset();
				durTimer.stop();
				durTimer.removeEventListener(TimerEvent.TIMER,onTimeChange);
			}	
		}
		
		private function onMouseMove(event:TouchEvent):void {
			var touch:Touch = event.getTouch(this);
			if(touch && touch.phase == TouchPhase.HOVER){
				controlsTimer.reset();
				controlsTimer.start();
				controls.show();
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_PLAYER_SHOW_CONTROLS));
			}	
		}
		
		protected function onTimeChange(event:TimerEvent):void {
			var timeToSet:int = Math.floor(nFauxOffset+ns.time);
			if(timeToSet < 1) timeToSet = 0;
			if(!isSeeking && !controls.isScrubbing) controls.setCurrentTime(timeToSet);
		}
		
		protected function onControlsTimer(event:TimerEvent):void {
			this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_PLAYER_HIDE_CONTROLS));
		}
		
		protected function onEncodeError(event:FFmpegEvent):void {
			trace("AVANE ERROR: ",event.params.message);

		}
		protected function onStreamData(event:StreamProviderEvent):void {
			if(ns)
				ns.appendBytes(event.data);
		}
		protected function onStreamClose(event:StreamProviderEvent):void {
			trace("--------------onStreamClose------------");
			trace(event);
			
			if(seekAfterEncodeFinish){
				streamer.init();
				OutputOptions.uri = "tcp:127.0.0.1:1234";
				avANE.encode();
			}else if(playAfterEncodeFinish){
				var obj:Object = JSON.parse(urlList[urlDrop.selected].value);
				uri = obj.uri;
				isLive = obj.live;
				controls.isLive = isLive;
				avANE.getProbeInfo(uri);
			}
			seekAfterEncodeFinish = false;
			playAfterEncodeFinish = false;
		}
		private function setupVideo():void {
			vidClient = new Object();
			vidClient.onMetaData = onMetaData;
			nc = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			ns.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			ns.client = vidClient;
			soundTransform.volume = 0.5;
			ns.soundTransform = soundTransform;
			
			videoTexture = Texture.fromNetStream(this.ns, Starling.current.contentScaleFactor, onTextureComplete);
			
			ns.bufferTime = 2;
			ns.play(null);
		}
		protected function onProbeInfo(event:ProbeEvent):void {
			var probe:Probe = event.params.data as Probe;
			//probe tells us about the video and audio codec. We can now determine how and if to transcode into a format Flash can play (h.264 & aac in flv container)
			
			if(isLive){
				videoDuration = 0;
			}else{
				videoDuration = probe.format.duration;
				startTime = probe.format.startTime;
				controls.setDuration(videoDuration);
				controls.updateProgress(1.0);
			}
			
			setupVideo();
			
			var inputOptions:InputOptions = new InputOptions();
			inputOptions.uri = uri;
			if(videoDuration > 0) OutputOptions.to = videoDuration;
			inputOptions.startTime = (nFauxOffset > 0) ? nFauxOffset : 0;
			
			InputStream.clear();
			InputStream.addInput(inputOptions);
			
			
			if(probe.audioStreams.length > 0){
				var outputAudioStream:OutputAudioStream = new OutputAudioStream();
				outputAudioStream.sourceIndex = 0;
				
				if(probe.audioStreams[0].codecName == "aac"){ // audio is already aac, just copy it!
					outputAudioStream.codec = "copy";
					if(probe.audioStreams[0].sampleRate > 48000){
						outputAudioStream.samplerate = 48000;
						outputAudioStream.bitrate = 448000;
					}
				}else{
					outputAudioStream.samplerate = 48000;
					outputAudioStream.bitrate = 448000;
					outputAudioStream.codec = "aac";
					outputAudioStream.channels = 2;
				}
				OutputOptions.addAudioStream(outputAudioStream);
			}	
			
		
			
			var videoStream:OutputVideoStream = new OutputVideoStream();
			videoStream.sourceIndex = 0;
			if(probe.videoStreams[0].codecName == "h264"){
				videoStream.codec = "copy";
			}else{
				if(hasHardWareAcceleration("dxva2"))
					inputOptions.hardwareAcceleration = "dxva2";
				else if(hasHardWareAcceleration("vda"))
					inputOptions.hardwareAcceleration = "vda";
					
				videoStream.codec = "libx264";
				videoStream.crf = 1;
				var x264Options:X264Options = new X264Options();
				x264Options.preset = X264Preset.ULTRA_FAST;
				x264Options.profile = X264Profile.MAIN;
				x264Options.level = "4.1";
				videoStream.encoderOptions = x264Options;
			}
			
			OutputOptions.addVideoStream(videoStream);
			OutputOptions.format = "flv";
			OutputOptions.realtime = true;
			streamer.init();
			OutputOptions.uri = "tcp:127.0.0.1:1234";
			avANE.setLogLevel(BuildMode.isDebugBuild() ? LogLevel.VERBOSE :  LogLevel.QUIET); 
			avANE.encode();
			
		}
			
		private function onMetaData(metadata:Object):void {
			if(metadata){
				
			}
		}
		
		protected function onNetStatus(event:NetStatusEvent):void {
			trace(event.info.code);
			switch(event.info.code){
				case "NetStream.Play.Stop":
					controls.reset();
					stopControlsTimer();
					stopDurationTimer();
					clearVideo();
					break;
				case "NetStream.SeekStart.Notify":
					isSeeking = true;
					showLoading();
					break;
				case "NetStream.Seek.Notify":
					isSeeking = false;
					showLoading();
					break;
				case "NetStream.Buffer.Empty":
					showLoading(true);
					break;
				case "NetStream.Buffer.Full":
					showLoading(false);
					break;
			}
		}
		
		protected function onTextureComplete():void {
			videoImage = new Image(videoTexture);
			videoImage.blendMode = BlendMode.NONE;
			videoImage.touchable = false;
			setSize();
			
			if(!durTimer)
				durTimer = new Timer(200);
			durTimer.addEventListener(TimerEvent.TIMER,onTimeChange);
			durTimer.start();
			
			controls.setDuration(videoDuration);
			
			//controls.doResize(_screenWidth);
			controls.y = 800-51;
			if(!this.contains(controls))
				addChild(controls);
			startControlsTimer();
			
			if(!this.hasEventListener(TouchEvent.TOUCH))
				this.addEventListener(TouchEvent.TOUCH, onMouseMove);
			
			
			if(!this.contains(videoImage))
				this.addChildAt(videoImage,0);
		}
		public function setSize():void {
			var scaleFactor:Number = 1280/videoTexture.nativeWidth;
			videoImage.scaleY = videoImage.scaleX = scaleFactor;
			videoImage.y = 80;
			
			if(videoTexture.nativeWidth == 1280)
				videoImage.textureSmoothing = TextureSmoothing.NONE;
			else
				videoImage.textureSmoothing = TextureSmoothing.BILINEAR;
			
		}
		protected function onNoProbeInfo(event:ProbeEvent):void {
			trace(event);
		}
		
		private function onPlayTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(playButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED){
				controls.reset();
				avANE.setLogLevel(BuildMode.isDebugBuild() ? LogLevel.INFO :  LogLevel.QUIET);
				Logger.enableLogToTextField = false;
				Logger.enableLogToTrace = true;
				Logger.enableLogToFile = false;
				
				//stop any existing playback
				stopDurationTimer();
				showLoading(true);
				if(streamer.connected){
					playAfterEncodeFinish = true;
					clearVideo();
				}else{
					clearVideo();
					
					var obj:Object = JSON.parse(urlList[urlDrop.selected].value);
					
					uri = obj.uri;
					isLive = obj.live;
					controls.isLive = isLive;
					avANE.getProbeInfo(uri);
				}

			}	
		}
		
		private function randomRange(minNum:Number, maxNum:Number):Number {
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}

		private function showLoading(b:Boolean=true):void {
			if(b && !loading.isRunning)
				loading.start();
			else if(loading.isRunning)
				loading.stop();
		}
		public function clearVideo():void {
			
			nFauxOffset = 0;
			
			if(streamer.connected)
				avANE.cancelEncode();
			OutputOptions.clear();
			
			if (this.contains(videoImage)) {
				this.removeChild(videoImage);
				videoImage.base.dispose();
				videoImage.dispose();
				videoImage = null;
				
				videoTexture.dispose();
				videoTexture.base.dispose();
				videoTexture = null;
				
				System.pauseForGCIfCollectionImminent(0);
			}
			if(ns) {
				ns.removeEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
				ns.dispose();
				ns.close();
				ns = null;
				nc = null;
			}
		}
	
		public function resume():void {
			this.visible = true;
			if(avANE){
				avANE.addEventListener(ProbeEvent.ON_PROBE_INFO,onProbeInfo);
				avANE.addEventListener(ProbeEvent.NO_PROBE_INFO,onNoProbeInfo);
				avANE.addEventListener(FFmpegEvent.ON_ENCODE_ERROR,onEncodeError);
			}
			if(streamer){
				streamer.addEventListener(StreamProviderEvent.ON_STREAM_DATA,onStreamData);
				streamer.addEventListener(StreamProviderEvent.ON_STREAM_CLOSE,onStreamClose);
			}
		}
		public function suspend():void {
			clearVideo();
			if(avANE){
				avANE.removeEventListener(ProbeEvent.ON_PROBE_INFO,onProbeInfo);
				avANE.removeEventListener(ProbeEvent.NO_PROBE_INFO,onNoProbeInfo);
				avANE.removeEventListener(FFmpegEvent.ON_ENCODE_ERROR,onEncodeError);
			}
			if(streamer){
				streamer.removeEventListener(StreamProviderEvent.ON_STREAM_DATA,onStreamData);
				streamer.removeEventListener(StreamProviderEvent.ON_STREAM_CLOSE,onStreamClose);
			}
			this.visible = false;
		}
		private function hasHardWareAcceleration(value:String):Boolean {
			for (var i:int=0, l:int=hwAccels.length; i<l; ++i){
				if(hwAccels[i].name == value)
					return true;
			}
			return false;
		}
	}
}
