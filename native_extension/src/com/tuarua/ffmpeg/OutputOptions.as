package com.tuarua.ffmpeg {
	import flash.globalization.DateTimeFormatter;
	[RemoteClass(alias="com.tuarua.ffmpeg.OutputOptions")]
	public class OutputOptions extends Object {
		/** 
		 * FFmpeg equivalent: -f.
		 * <p>Force output file format. The format is normally guessed from the file extension for output files, 
		 * so this option is not needed in most cases. </p>
		 * @default null which ommits it from the params used 
		 */	
		public static var format:String;
		/** 
		 * <p>output file name. </p>
		 */
		public static var uri:String;
		public static var videoStreams:Vector.<OutputVideoStream> = new Vector.<OutputVideoStream>;
		public static var audioStreams:Vector.<OutputAudioStream> = new Vector.<OutputAudioStream>;
		public static var attachments:Vector.<Attachment> = new Vector.<Attachment>;
		public static var metadata:MetaData; //http://wiki.multimedia.cx/index.php?title=FFmpeg_Metadata
		
		public static var extraOptions:Vector.<*>; //eg hls
		/** 
		 * FFmpeg equivalent: -movflags +faststart.
		 * <p>Normally, a MOV/MP4 file has all the metadata about all packets stored in one location 
		 * (written at the end of the file, it can be moved to the start for better playback.</p>
		 * @default false which ommits it from the params used 
		 */	
		public static var fastStart:Boolean = false;
		public static var videoFilters:Vector.<String> = new Vector.<String>;
		public static var complexFilters:Vector.<String> = new Vector.<String>;
		public static var bitStreamFilters:Vector.<BitStreamFilter> = new Vector.<BitStreamFilter>;
		
		public static var copyAllVideoStreams:Boolean = false;
		public static var copyAllAudioStreams:Boolean = false;
		/** 
		 * FFmpeg equivalent: -bufsize.
		 * <p>Sets the buffer size</p>
		 * @default -1 which ommits it from the params used 
		 */	
		public static var bufferSize:int = -1;
		/** 
		 * FFmpeg equivalent: -maxrate.
		 * <p>Sets the max rate</p>
		 * @default -1 which ommits it from the params used 
		 */	
		public static var maxRate:int = -1;
		/** 
		 * FFmpeg equivalent: -t.
		 * <p>Stop writing the output after its duration reaches duration. </p>
		 * @default -1 which ommits it from the params used 
		 */	
		public static var duration:Number = -1.0;
		/** 
		 * FFmpeg equivalent: -to.
		 * <p>Stop writing the output at position.</p>
		 * @default -1 which ommits it from the params used 
		 */
		public static var to:Number = -1.0;
		
		/** 
		 * FFmpeg equivalent: -fs.
		 * <p>Set the file size limit, expressed in bytes. No further chunk of bytes is written after 
		 * the limit is exceeded. The size of the output file is slightly more than the requested file size. </p>
		 * @default -1 which ommits it from the params used 
		 */
		public static var fileSizeLimit:int = -1;
		//private static var _timestamp:String;
		//public static var program:String;//need
		
		
		/** 
		 * FFmpeg equivalent: -pre.
		 * <p>Specify the preset for matching stream(s).</p>
		 * @default null which ommits it from the params used 
		 */
		public static var preset:String;
		/** 
		 * FFmpeg equivalent: -target.
		 * <p>Specify target file type (vcd, svcd, dvd, dv, dv50). type may be prefixed with pal-, 
		 * ntsc- or film- to use the corresponding standard. 
		 * All the format options (bitrate, codecs, buffer sizes) are then set automatically.</p>
		 * @default null which ommits it from the params used 
		 */
		public static var target:String;
		/** 
		 * FFmpeg equivalent: -r.
		 * <p>Set the input frame rate in frames per second. </p>
		 * @default 0.0 which ommits it from the params used 
		 */	
		public static var frameRate:Number = 0.0;
		/** 
		 * <p>Write output at native frame rate. This is an additional feature not available in FFmpeg 
		 * and differs from realtime input. </p>
		 * @default false
		 */
		public static var realtime:Boolean = false;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function OutputOptions(){}
		public static function addOverlay(overlay:Overlay):void {
			var inputOptions:InputOptions = new InputOptions();
			inputOptions.uri = overlay.fileName;
			InputStream.addInput(inputOptions);
			var str:String = "overlay="+overlay.x+":"+overlay.y;
			if(overlay.inTime > -1 && overlay.outTime > -1)
				str += ":enable='between(t,"+overlay.inTime+","+overlay.outTime+")'";
			complexFilters.push(str);
		}
		public static function addVideoStream(_videoStream:OutputVideoStream):void {
			if(videoStreams == null)
				videoStreams = new Vector.<OutputVideoStream>;
			videoStreams.push(_videoStream);
		}
		public static function addAudioStream(_audioStream:OutputAudioStream):void {
			if(audioStreams == null)
				audioStreams = new Vector.<OutputAudioStream>
			audioStreams.push(_audioStream);
		}
		public static function addAttachment(_attachment:Attachment):void {
			if(attachments == null)
				attachments = new Vector.<Attachment>;
			attachments.push(_attachment);
		}
		
		public static function addExtraOptions(_extra:*):void {
			if(extraOptions == null)
				extraOptions = new Vector.<*>;
			extraOptions.push(_extra);
		}
		
		public static function clear():void {
			format = null;
			uri = null;
			fastStart = false;
			copyAllVideoStreams = false;
			copyAllAudioStreams = false;
			metadata = null;
			duration = -1;
			to = -1;
			fileSizeLimit = -1;
		//	_timestamp = null;

				
			bufferSize = -1;
			maxRate = -1;
			preset = null;
			target = null;
			frameRate = 0;
			realtime = false;
			
			if(videoStreams)
				videoStreams.splice(0, videoStreams.length);
			videoStreams = null;
			
			if(audioStreams)
				audioStreams.splice(0, audioStreams.length);
			audioStreams = null;
			
			if(attachments)
				attachments.splice(0, attachments.length);
			attachments = null;
			
			if(videoFilters) //why am I not clearing them again ?
				videoFilters.splice(0, videoFilters.length);
			
			if(bitStreamFilters)
				bitStreamFilters.splice(0, bitStreamFilters.length);
			
			if(complexFilters)
				complexFilters.splice(0, complexFilters.length);
			
			if(extraOptions)
				extraOptions.splice(0, extraOptions.length);
			
		}
		public static function burnSubtitles(path:String):void {
			videoFilters.push("subtitles="+path);
		}
		public static function addVideoFilter(value:String):void {
			videoFilters.push(value);
		}
		public static function addBitStreamFilter(value:String,type:String="v"):void {
			var bsf:BitStreamFilter = new BitStreamFilter(type,value);
			bitStreamFilters.push(bsf);
		}
		/*
		public static function getTimestamp():String {
			return _timestamp;
		}
		public static function set timestamp(date:Date):void {
			_timestamp = unixToDate(date.getTime()/1000);
		}
		*/
		private static function unixToDate(_val:uint):String {
			var d:Date = new Date(_val*1000);
			var dtf:DateTimeFormatter = new DateTimeFormatter("en-UK");
			dtf.setDateTimePattern("y-MM-d HH:mm:ss");
			return dtf.format(d)
		}
		
	}
}

/*
-q[:stream_specifier] q (output,per-stream)

-qscale[:stream_specifier] q (output,per-stream)


Use fixed quality scale (VBR). The meaning of q/qscale is codec-dependent. If qscale is used without a stream_specifier then it applies only to the video stream, this is to maintain compatibility with previous behavior and as specifying the same codec specific value to 2 different codecs that is audio and video generally is not what is intended when no stream_specifier is used. 

-filter[:stream_specifier] filtergraph (output,per-stream)


Create the filtergraph specified by filtergraph and use it to filter the stream. 

filtergraph is a description of the filtergraph to apply to the stream, and must have a single input and a single output of the same type of the stream. In the filtergraph, the input is associated to the label in, and the output to the label out. See the ffmpeg-filters manual for more information about the filtergraph syntax. 

See the -filter_complex option if you want to create filtergraphs with multiple inputs and/or outputs. 

-filter_script[:stream_specifier] filename (output,per-stream)


This option is similar to -filter, the only difference is that its argument is the name of the file from which a filtergraph description is to be read. 

-pre[:stream_specifier] preset_name (output,per-stream)


Specify the preset for matching stream(s). 

*/