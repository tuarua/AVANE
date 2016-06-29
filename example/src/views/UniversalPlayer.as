package views {
	import com.tuarua.AVANE;
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
	import com.tuarua.ffprobe.AudioStream;
	import com.tuarua.ffprobe.Probe;
	import com.tuarua.ffprobe.events.ProbeEvent;
	
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.System;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	import views.forms.DropDown;

	public class UniversalPlayer extends Sprite {
		private var avANE:AVANE;
		private var urlDrop:DropDown;
		private var urlList:Vector.<Object> = new Vector.<Object>;
		private var playButton:SimpleButton = new SimpleButton("Play");
		private var streamer:Streamer;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var vidClient:Object;
		private var uri:String;private var videoImage:Image;
		private var videoTexture:Texture;
		private var loading:LoadingIcon = new LoadingIcon();
		private var soundTransform:SoundTransform = new SoundTransform();
		private var circularLoader:CircularLoader;
		public function UniversalPlayer(_avANE:AVANE) {
			super();
			avANE = _avANE;
			
			avANE.addEventListener(ProbeEvent.ON_PROBE_INFO,onProbeInfo);
			avANE.addEventListener(ProbeEvent.NO_PROBE_INFO,onNoProbeInfo);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_ERROR,onEncodeError);
			
			streamer = new Streamer("127.0.0.1",1235);
			streamer.addEventListener(StreamProviderEvent.ON_STREAM_DATA,onStreamData);
			streamer.addEventListener(StreamProviderEvent.ON_STREAM_CLOSE,onStreamClose);
			
			urlList.push({value:"https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4",label:"MP4 H.264   -   https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4"});
			urlList.push({value:"http://video.h265files.com/TearsOfSteel_720p_h265.mkv",label:"MKV HEVC   -   http://video.h265files.com/TearsOfSteel_720p_h265.mkv"});
			urlList.push({value:"http://yt-dash-mse-test.commondatastorage.googleapis.com/media/feelings_vp9-20130806-247.webm",label:"WEBM VP9   -   http://yt-dash-mse-test.commondatastorage.googleapis.com/media/feelings_vp9-20130806-247.webm"});
			urlList.push({value:"http://s1.demo-world.eu/hd_trailers.php?file=samsung_canadian_scenery-DWEU.mkv",label:"MKV H.264   -   http://s1.demo-world.eu/hd_trailers.php?file=samsung_canadian_scenery-DWEU.mkv"});
			urlList.push({value:"http://vevoplaylist-live.hls.adaptive.level3.net/vevo/ch1/06/prog_index.m3u8",label:"HLS Vevo live   -   http://vevoplaylist-live.hls.adaptive.level3.net/vevo/ch1/06/prog_index.m3u8"});
			
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
		
		protected function onEncodeError(event:FFmpegEvent):void {
			trace("AVANE ERROR: ",event.params.message);
		}
		protected function onStreamData(event:StreamProviderEvent):void {
			if(ns)
				ns.appendBytes(event.data);
		}
		protected function onStreamClose(event:StreamProviderEvent):void {
			trace(event);
		}
		protected function onProbeInfo(event:ProbeEvent):void {
			var probe:Probe = event.params.data as Probe;
			//probe tells us about the video and audio codec. We can now determine how and if to transcode into a format Flash can play (h.264 & aac in flv container)
			
			vidClient = new Object();
			vidClient.onMetaData = onMetaData;
			nc = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			ns.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			ns.client = vidClient;
			ns.bufferTime = 5;
			soundTransform.volume = 0.5;
			ns.soundTransform = soundTransform;
			
			videoTexture = Texture.fromNetStream(this.ns, Starling.current.contentScaleFactor, onTextureComplete);

			ns.bufferTime = 2;
			ns.play(null);
			
			var inputOptions:InputOptions = new InputOptions();
			inputOptions.uri = uri;
					
			//inputOptions.startTime = 15;
			//inputOptions.realtime = true;
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
			OutputOptions.uri = "tcp:127.0.0.1:1235";
			avANE.setLogLevel(LogLevel.INFO);
			avANE.encode();
			
		}
			
		private function onMetaData(metadata:Object):void {
			if(metadata){
				
			}
		}
		
		protected function onNetStatus(event:NetStatusEvent):void {
			trace(event.info.code);
			switch(event.info.code){
				case "NetStream.Buffer.Empty":
					showLoading(true);
					break;
				case "NetStream.Buffer.Full":
					showLoading(false);
					break;
			}
		}
		
		protected function onTextureComplete():void {videoImage = new Image(videoTexture);
			videoImage.blendMode = BlendMode.NONE;
			videoImage.touchable = false;
			setSize();
			if(!this.contains(videoImage))
				this.addChildAt(videoImage,0);
		}
		public function setSize():void {
			var scaleFactor:Number = 1280/videoTexture.nativeWidth;
			videoImage.scaleY = videoImage.scaleX = scaleFactor;
			videoImage.y = 80;
			
			if(videoTexture.nativeWidth == 1280)
				videoImage.smoothing = TextureSmoothing.NONE;
			else
				videoImage.smoothing = TextureSmoothing.BILINEAR;
			
		}
		protected function onNoProbeInfo(event:ProbeEvent):void {
			trace(event);
		}
		
		private function onPlayTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(playButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED){
				
				avANE.setLogLevel(LogLevel.INFO);
				Logger.enableLogToTextField = false;
				Logger.enableLogToTrace = true;
				Logger.enableLogToFile = false;
				
				//stop any existing playback
				clearVideo();
				showLoading(true);
				uri = urlList[urlDrop.selected].value;
				avANE.getProbeInfo(uri);
			}	
		}
		private function showLoading(b:Boolean=true):void {
			if(b && !loading.isRunning)
				loading.start();
			else if(loading.isRunning)
				loading.stop();
		}
		public function clearVideo():void {
			
			//why is this being called at start
			//it clears OutputOptions !!
			
			if(streamer.connected){
				avANE.cancelEncode();
			}
				
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
	}
}