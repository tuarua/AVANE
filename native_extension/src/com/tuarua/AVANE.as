package com.tuarua {
	import com.tuarua.ffmpeg.Attachment;
	import com.tuarua.ffmpeg.BitStreamFilter;
	import com.tuarua.ffmpeg.GlobalOptions;
	import com.tuarua.ffmpeg.InputOptions;
	import com.tuarua.ffmpeg.InputStream;
	import com.tuarua.ffmpeg.Logger;
	import com.tuarua.ffmpeg.OutputAudioStream;
	import com.tuarua.ffmpeg.OutputOptions;
	import com.tuarua.ffmpeg.OutputVideoStream;
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
	import com.tuarua.ffmpeg.gets.Layouts;
	import com.tuarua.ffmpeg.gets.PixelFormat;
	import com.tuarua.ffmpeg.gets.Protocols;
	import com.tuarua.ffmpeg.gets.SampleFormat;
	import com.tuarua.ffmpeg.constants.LogLevel;
	import com.tuarua.ffprobe.Probe;
	import com.tuarua.ffprobe.events.ProbeEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.globalization.DateTimeFormatter;
	import com.tuarua.ffmpeg.gets.CaptureDevice;
	
	public class AVANE extends EventDispatcher {
		private var extensionContext:ExtensionContext;
		private var _inited:Boolean = false;
		private var timestamp:Date;
		private var _logLevel:int = LogLevel.QUIET;
		public function AVANE() {
			initiate();
		}
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		protected function initiate():void {
			trace("[AVANE] Initalizing ANE...");
			try {
				extensionContext = ExtensionContext.createExtensionContext("com.tuarua.AVANE", null);
				extensionContext.addEventListener(StatusEvent.STATUS, gotEvent);
			} catch (e:Error) {
				trace("[AVANE] ANE Not loaded properly.  Future calls will fail.");
			}
		}
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		protected function gotEvent(event:StatusEvent):void {
			switch (event.level) {
				case "TRACE":
					trace(event.code);
					break;
				case "INFO":
					Logger.logToTrace(event.code);
					Logger.logToFile(event.code);
					break;
				case "INFO_HTML":
					if(Logger.inited)
						Logger.logToTextField(event.code);
					break;
				case "ON_PROBE_INFO":
					this.dispatchEvent(new ProbeEvent(ProbeEvent.ON_PROBE_INFO,{data:extensionContext.call("getProbeInfo") as Probe}));
					break;
				case "NO_PROBE_INFO":
					this.dispatchEvent(new ProbeEvent(ProbeEvent.NO_PROBE_INFO,null));
					break;
				case "ON_ENCODE_START":
					this.dispatchEvent(new FFmpegEvent(FFmpegEvent.ON_ENCODE_START,null));
					break;
				case "ON_ENCODE_FINISH":
					this.dispatchEvent(new FFmpegEvent(FFmpegEvent.ON_ENCODE_FINISH,null));
					break;
				case "ON_ENCODE_ERROR":
					this.dispatchEvent(new FFmpegEvent(FFmpegEvent.ON_ENCODE_ERROR,{message:event.code}));
					break;
				case "Encode.ERROR_MESSAGE":
					this.dispatchEvent(new FFmpegEvent(FFmpegEvent.ON_ENCODE_ERROR,{message:event.code}));
					break;
                case "Encode.FATAL_MESSAGE":
                    this.dispatchEvent(new FFmpegEvent(FFmpegEvent.ON_ENCODE_FATAL,{message:event.code}));
                    break;
				case "ON_ENCODE_PROGRESS":
					this.dispatchEvent(new FFmpegEvent(FFmpegEvent.ON_ENCODE_PROGRESS,JSON.parse(event.code)));
					break;
			}
		}
		public function isSupported():Boolean {
			return extensionContext.call("isSupported"); 
		}
		
		public function getProbeInfo(filename:String,playlist:String=""):void {
			extensionContext.call("triggerProbeInfo",filename,playlist);
		}
		
		public function getFilters():Vector.<Filter>{
			return extensionContext.call("getFilters") as Vector.<Filter>;
		}
		public function getPixelFormats():Vector.<PixelFormat> {
			return extensionContext.call("getPixelFormats") as Vector.<PixelFormat>;
		}
		public function getLayouts():Layouts {
			return extensionContext.call("getLayouts") as Layouts;
		}
		public function getColors():Vector.<Color> {
			return extensionContext.call("getColors") as Vector.<Color>;
		}
		public function getProtocols():Protocols {
			return extensionContext.call("getProtocols") as Protocols;
		}
		public function getBitStreamFilters():Vector.<com.tuarua.ffmpeg.gets.BitStreamFilter> {
			return extensionContext.call("getBitStreamFilters") as Vector.<com.tuarua.ffmpeg.gets.BitStreamFilter>;
		}
		public function getCodecs():Vector.<Codec> {
			return extensionContext.call("getCodecs") as Vector.<Codec>;
		}
		public function getDecoders():Vector.<Decoder> {
			return extensionContext.call("getDecoders") as Vector.<Decoder>;
		}
		public function getEncoders():Vector.<Encoder> {
			return extensionContext.call("getEncoders") as Vector.<Encoder>;
		}
		public function getHardwareAccelerations():Vector.<HardwareAcceleration> {
			return extensionContext.call("getHardwareAccelerations") as Vector.<HardwareAcceleration>;
		}
		public function getDevices():Vector.<Device> {
			return extensionContext.call("getDevices") as Vector.<Device>;
		}
		public function getAvailableFormats():Vector.<AvailableFormat> {
			return extensionContext.call("getAvailableFormats") as Vector.<AvailableFormat>;
		}
		/** 
		 * <p>Returns license information for the FFmpeg libraries used</p>
		 * 
		 * @example
		 * <listing version="3.0">avANE.getLicense();</listing>
		 */ 
		public function getLicense():String {
			return extensionContext.call("getLicense")as String;
		}
		/** 
		 * <p>Returns version information for the FFmpeg libraries used</p>
		 * 
		 * @example
		 * <listing version="3.0">avANE.getVersion();</listing>
		 */ 
		public function getVersion():String {
			return extensionContext.call("getVersion")as String;
		}
		public function getBuildConfiguration():String {
			return extensionContext.call("getBuildConfiguration") as String;
		}
		public function getSampleFormats():Vector.<SampleFormat> {
			return extensionContext.call("getSampleFormats") as Vector.<SampleFormat>;
		}
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		private function cliParse(str:String, lookForQuotes:Boolean=true):Vector.<String> {
			var args:Vector.<String> = new Vector.<String>();
			var readingPart:Boolean = false;
			var part:String = "";
			for(var i:int=0; i<str.length; i++) {
				if(str.charAt(i) === " " && !readingPart) {
					args.push(part);
					part = "";
				} else {
					if(str.charAt(i) === '\"' && lookForQuotes)
						readingPart = !readingPart;
					else
						part += str.charAt(i);
				}
			}
			args.push(part);
			return args;
		}
		public function encode(classicString:String=null):void {
			var args:Vector.<String> = new Vector.<String>();
			if(classicString){
				args = cliParse(classicString);
			}else{
				args.push("-nostdin");
				if(GlobalOptions.overwriteOutputFiles)
					args.push("-y");
				if(GlobalOptions.ignoreUnknown)
					args.push("-ignore_unknown");
				if(GlobalOptions.copyUnknown)
					args.push("-copy_unknown");
				if(GlobalOptions.maxErrorRate > 0)
					args.push("-max_error_rate", GlobalOptions.maxErrorRate.toString());
				if(GlobalOptions.timeLimit > 0)
					args.push("-timelimit", GlobalOptions.timeLimit.toString());
				if(GlobalOptions.vsync != "-1")
					args.push("-vsync", GlobalOptions.vsync);
				if(GlobalOptions.fDropThreshold > -1.1)
					args.push("-frame_drop_threshold", GlobalOptions.fDropThreshold.toString());
				if(GlobalOptions.copyTs)
					args.push("-copyts");
				if(GlobalOptions.startAtZero)
					args.push("-start_at_zero");
				if(GlobalOptions.copyTb > -1)
					args.push("-copytb", GlobalOptions.copyTb.toString());
				
				var inputOptions:InputOptions;
				for (var i:int=0, l:int=InputStream.options.length; i<l; ++i){
					inputOptions = InputStream.options[i];
					if(inputOptions.threads > 0)
						args.push("-threads",inputOptions.threads.toString());
					if(inputOptions.playlist > -1)
						args.push("-playlist",inputOptions.playlist.toString());
					if(inputOptions.realtime)
						args.push("-re");
					if(OutputOptions.realtime)//custom to avane
						args.push("-re2");
					if(inputOptions.startTime > 0)
						args.push("-ss",inputOptions.startTime.toString());
					if(inputOptions.format)
						args.push("-f",inputOptions.format);
					if(inputOptions.streamLoop > 0)
						args.push("-stream_loop",inputOptions.streamLoop.toString());
					if(inputOptions.duration > 0)
						args.push("-t",inputOptions.duration.toString());
					if(inputOptions.frameRate > 0)
						args.push("-r",inputOptions.frameRate.toString());
					if(inputOptions.size)
						args.push("-s",inputOptions.size);
					if(inputOptions.videoCodec)
						args.push("-vcodec",inputOptions.videoCodec);
					if(inputOptions.audioCodec)
						args.push("-acodec",inputOptions.audioCodec);
					if(inputOptions.pixelFormat)
						args.push("-pix_fmt",inputOptions.pixelFormat);
					if(inputOptions.inputTimeOffset > 0)
						args.push("-itsoffset",inputOptions.inputTimeOffset.toString());
					if(inputOptions.hardwareAcceleration)
						args.push("-hwaccel",inputOptions.hardwareAcceleration);
					
					
					if(inputOptions.extraOptions){
						try {
							var obj:*;
							for (var v:int=0, l6:int=inputOptions.extraOptions.length; v<l6; ++v){
								obj = inputOptions.extraOptions[v];
								var vecArb:Vector.<Object> = obj.getAsVector();
								for each(var optArb:Object in vecArb) {
									args.push("-"+optArb.key, optArb.value);
								}
							}
						}catch(e:Error){
							trace(e.message);
						}
					}
					
					args.push("-i",inputOptions.uri);
				}
				
				if(OutputOptions.copyAllAudioStreams){
					args.push("-map", "0:a");
					args.push("-c:a","copy");
				}else{
					if(OutputOptions.audioStreams){
						var aStream:OutputAudioStream;
						for (var j:int=0, l2:int=OutputOptions.audioStreams.length; j<l2; ++j){
							aStream = OutputOptions.audioStreams[j];
							args.push("-map", "0:a:"+aStream.sourceIndex.toString());
							args.push("-c:a:"+j.toString(), aStream.codec);
							if(aStream.samplerate > -1)
								args.push("-ar:a:"+j.toString(), aStream.samplerate.toString());
							if(aStream.bitrate > -1)
								args.push("-ab:a:"+j.toString(), aStream.bitrate.toString());
							if(aStream.frames > -1)
								args.push("-frames:a:"+j.toString(), aStream.frames.toString());
							args.push("-ac", aStream.channels.toString());
						}
					}
				}
				if(OutputOptions.copyAllVideoStreams){
					args.push("-map", "0:v");
					args.push("-c:v","copy");
				}else{
					if(OutputOptions.videoStreams){
						var vStream:OutputVideoStream;
						for (var k:int=0, l3:int=OutputOptions.videoStreams.length; k<l3; ++k){
							vStream = OutputOptions.videoStreams[k];
							args.push("-map", "0:v:"+vStream.sourceIndex.toString());
							args.push("-c:v:"+k.toString(), vStream.codec);
							if(vStream.bitrate > -1)
								args.push("-b:v:"+k.toString(), vStream.bitrate.toString());
							if(vStream.frames > -1)
								args.push("-frames:v:"+k.toString(), vStream.frames.toString());
							if(vStream.pixelFormat)
								args.push("-pix_fmt:v:"+k.toString(), vStream.pixelFormat);
							if(vStream.encoderOptions){
								var vec:Vector.<Object> = vStream.encoderOptions.getAsVector();
								for each(var opt:Object in vec){
									args.push("-"+opt.key+":v:"+vStream.sourceIndex.toString(), opt.value);
								}	
							}
							if(vStream.crf > -1)
								args.push("-crf", vStream.crf.toString());
							if(vStream.qp > -1)
								args.push("-qp", vStream.qp.toString());
							if(vStream.advancedEncOpts && vStream.advancedEncOpts.getAsString())
								args.push("-"+vStream.advancedEncOpts.type, "\""+vStream.advancedEncOpts.getAsString()+"\"");	
						}
					}
					if(OutputOptions.videoFilters && OutputOptions.videoFilters.length > 0)
						args.push("-vf", OutputOptions.videoFilters.toString());
					
					if(OutputOptions.bitStreamFilters && OutputOptions.bitStreamFilters.length > 0){
						for each(var bsf:com.tuarua.ffmpeg.BitStreamFilter in OutputOptions.bitStreamFilters){
							args.push("-bsf:"+bsf.type, bsf.value);
						}
					}
					
					if(OutputOptions.complexFilters && OutputOptions.complexFilters.length > 0)
						args.push("-filter_complex", OutputOptions.complexFilters.toString());
					if(OutputOptions.format)
						args.push("-f", OutputOptions.format);
					if(OutputOptions.fastStart)
						args.push("-movflags", "+faststart");
					if(OutputOptions.to > -1)
						args.push("-to", OutputOptions.to.toString());
					if(OutputOptions.duration > -1)
						args.push("-t", OutputOptions.duration.toString());
					if(OutputOptions.bufferSize > -1)
						args.push("-bufsize", OutputOptions.bufferSize.toString());
					if(OutputOptions.maxRate > -1)
						args.push("-maxrate", OutputOptions.maxRate.toString());
					if(OutputOptions.fileSizeLimit > -1)
						args.push("-fs", OutputOptions.fileSizeLimit.toString());
					if(OutputOptions.frameRate > 0)
						args.push("-r", OutputOptions.frameRate.toString());
					//if(OutputOptions.getTimestamp()) //args.push("-timestamp", OutputOptions.getTimestamp());
						//args.push("-timestamp", "now");
					if(OutputOptions.preset)
						args.push("-pre", OutputOptions.preset);
					if(OutputOptions.target)
						args.push("-target", OutputOptions.target);
					if(OutputOptions.attachments){
						var attch:Attachment;
						for (var m:int=0, l4:int=OutputOptions.attachments.length; m<l4; ++m){
							attch = OutputOptions.attachments[m];
							args.push("-metadata:s:t" + m,"mimetype=" + attch.getMimeType());
						}
					}
					if(OutputOptions.metadata){
						var vecMeta:Vector.<String> = OutputOptions.metadata.getAsVector();
						for (var n:int=0, l5:int=vecMeta.length; n<l5; ++n)
							args.push("-metadata",vecMeta[n]);
					}
				}
				
				if(OutputOptions.extraOptions){
					try {
						var obji:*;
						for (var u:int=0, l7:int=OutputOptions.extraOptions.length; u<l7; ++u){
							obji = OutputOptions.extraOptions[u];
							var vecXtra:Vector.<Object> = obji.getAsVector();
							for each(var optXtra:Object in vecXtra){
								args.push("-"+optXtra.key, optXtra.value);
							}
						}
					}catch(e:Error){
						trace(e.message);
					}
				}
				
				
				args.push(OutputOptions.uri);
			}
			
			if(_logLevel >= LogLevel.INFO)
				trace("constructed FFmpeg cli sent to encode:",args);
			
			extensionContext.call("encode",args);
		}
		
		public function setLogLevel(level:int):void {
			_logLevel = level;
			extensionContext.call("setLogLevel",_logLevel);
		}
		public function cancelEncode():Boolean {
			return extensionContext.call("cancelEncode");
		}
		public function pauseEncode(value:Boolean):Boolean {
			return extensionContext.call("pauseEncode",value);
		}
		/**
		 * 
		 * @return returns vector of Capture Devices
		 * <p>Currently only available on Windows (DirectShow devices)</p>
		 * 
		 */		
		public function getCaptureDevices():Vector.<CaptureDevice> {
			return extensionContext.call("getCaptureDevices") as Vector.<CaptureDevice>;
		}
		
		public function dispose():void {
			if (!extensionContext) {
				trace("[AVANE] Error. ANE Already in a disposed or failed state...");
				return;
			}
			trace("[AVANE] Unloading ANE...");
			extensionContext.removeEventListener(StatusEvent.STATUS, gotEvent);
			extensionContext.dispose();
			extensionContext = null;
		}

	}
}