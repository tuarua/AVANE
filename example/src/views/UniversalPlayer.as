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
	import com.tuarua.ffmpeg.gets.HardwareAcceleration;
	import com.tuarua.ffprobe.AudioStream;
	import com.tuarua.ffprobe.Probe;
	import com.tuarua.ffprobe.events.ProbeEvent;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	
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
		private var videoImage:Image;
		private var videoTexture:Texture;
		private var loading:LoadingIcon = new LoadingIcon();
		private var soundTransform:SoundTransform = new SoundTransform();
		private var circularLoader:CircularLoader;
		private var isTwitch:Boolean = false;
		private var twitchChannel:String;

		private var hwAccels:Vector.<HardwareAcceleration>;
		public function UniversalPlayer(_avANE:AVANE) {
			super();
			avANE = _avANE;
			
			hwAccels = avANE.getHardwareAccelerations();
			
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
			urlList.push({value:"http://vevoplaylist-live.hls.adaptive.level3.net/vevo/ch2/06/prog_index.m3u8",label:"HLS Vevo live   -   http://vevoplaylist-live.hls.adaptive.level3.net/vevo/ch1/06/prog_index.m3u8"});
			urlList.push({value:"twitch",label:"HLS Twitch live  60fps -   random channel"});
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
			
			setupVideo();
			
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
			OutputOptions.uri = "tcp:127.0.0.1:1235";
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
			if(!this.contains(videoImage))
				this.addChildAt(videoImage,0);
		}
		public function setSize():void {
			trace(videoTexture.nativeWidth);
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
				
				avANE.setLogLevel(BuildMode.isDebugBuild() ? LogLevel.INFO :  LogLevel.QUIET);
				Logger.enableLogToTextField = false;
				Logger.enableLogToTrace = true;
				Logger.enableLogToFile = false;
				
				//stop any existing playback
				
				showLoading(true);
				if(streamer.connected){
					avANE.addEventListener(FFmpegEvent.ON_ENCODE_FINISH,onPlayAfterCancel);
					clearVideo();
				}else{
					clearVideo();
					isTwitch = (urlList[urlDrop.selected].value == "twitch");
					if(isTwitch){
						var streamLdr:URLLoader = new URLLoader();
						streamLdr.addEventListener(Event.COMPLETE, onTwitchStream);
						streamLdr.load(new URLRequest("https://api.twitch.tv/kraken/streams"));	
					}else{
						uri = urlList[urlDrop.selected].value;
						avANE.getProbeInfo(uri);
					}
				}
				
			}	
		}
		private function onPlayAfterCancel(event:FFmpegEvent):void {
			isTwitch = (urlList[urlDrop.selected].value == "twitch");
			if(isTwitch){
				var streamLdr:URLLoader = new URLLoader();
				streamLdr.addEventListener(Event.COMPLETE, onTwitchStream);
				streamLdr.load(new URLRequest("https://api.twitch.tv/kraken/streams"));	
			}else{
				uri = urlList[urlDrop.selected].value;
				avANE.getProbeInfo(uri);
			}
		}
		private function randomRange(minNum:Number, maxNum:Number):Number {
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}

		protected function onTwitchStream(event:Event):void {
			var result:String = event.target.data;
			var parsedObj:Object = JSON.parse(result);
			var niceOptions:Array = new Array();
			for each(var obj:Object in parsedObj.streams){
				if(obj.average_fps > 50 && obj.channel.language == "en")
					niceOptions.push(obj);
			}
			
			twitchChannel = niceOptions[randomRange(0,niceOptions.length-1)].channel.name;
			
			var url:String = "http://api.twitch.tv/api/channels/"+twitchChannel+"/access_token";
			var twitchTokenLdr:URLLoader = new URLLoader();
			twitchTokenLdr.addEventListener(Event.COMPLETE, onTwitchToken);
			twitchTokenLdr.load(new URLRequest(url));
			
		}
		
		
		protected function onTwitchm3u8Loaded(event:Event):void{
			var m3u8:String = event.target.data;
			var lines:Array = m3u8.split("\n");
			var line:String;
			var sourceArr:Array = new Array();
			var sourceObj:Object ;
			for (var i:int = 0; i < lines.length;i++){
				line = lines[i];
				if(line.indexOf("#EXT-X-MEDIA:TYPE=VIDEO") == 0){
					var itms:Array = line.split(",");
					sourceObj = new Object()
					sourceObj.name = itms[2];
					sourceObj.name = sourceObj.name.replace(new RegExp("NAME=", "g"),""); ;
					sourceObj.name = sourceObj.name.replace(new RegExp('"', "g"),"");
					sourceObj.name = sourceObj.name.toLowerCase();
					sourceObj.uri = lines[i+2];
					if(sourceObj.name == "source") uri = sourceObj.uri;
					sourceArr.push(sourceObj);
				}
			}
				
			setupVideo();
			ns.bufferTime = 1;
			
			//don't probe - already know we need to transcode
			var inputOptions:InputOptions = new InputOptions();
			
			inputOptions.uri = uri;
			InputStream.clear();
			InputStream.addInput(inputOptions);
			var outputAudioStream:OutputAudioStream = new OutputAudioStream();
			outputAudioStream.sourceIndex = 0;
			outputAudioStream.samplerate = 48000;
			outputAudioStream.bitrate = 448000;
			outputAudioStream.codec = "aac";
			outputAudioStream.channels = 2;
			OutputOptions.addAudioStream(outputAudioStream);
			
			
			var videoStream:OutputVideoStream = new OutputVideoStream();
			videoStream.sourceIndex = 0;
			videoStream.codec = "copy";
			
			OutputOptions.addVideoStream(videoStream);
			OutputOptions.format = "flv";
			streamer.init();
			OutputOptions.uri = "tcp:127.0.0.1:1235";
			avANE.setLogLevel(BuildMode.isDebugBuild() ? LogLevel.VERBOSE :  LogLevel.QUIET);
			avANE.encode();
			
			
		}
		
		protected function onTwitchToken(event:Event):void {
			var result:String = event.target.data;
			var parsedObj:Object = JSON.parse(result);
			var sig:String = parsedObj.sig;
			var token:String = parsedObj.token;
			var m3u8Url:String = "http://usher.twitch.tv/api/channel/hls/"+twitchChannel+".m3u8?player=twitchweb&token="+token+"&sig="+sig+"&$allow_audio_only=true&allow_source=true&type=any&p=1243565"
				
			
			var m3u8Ldr:URLLoader = new URLLoader();
			m3u8Ldr.addEventListener(Event.COMPLETE, onTwitchm3u8Loaded);
			//m3u8Ldr.addEventListener(IOErrorEvent.IO_ERROR, onm3u8Error);
			m3u8Ldr.load(new URLRequest(m3u8Url));
			
		}
		private function showLoading(b:Boolean=true):void {
			if(b && !loading.isRunning)
				loading.start();
			else if(loading.isRunning)
				loading.stop();
		}
		public function clearVideo():void {
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
