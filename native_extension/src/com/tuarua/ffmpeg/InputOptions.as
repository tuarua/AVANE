package com.tuarua.ffmpeg {
	public class InputOptions extends Object {
		/** 
		 * FFmpeg equivalent: -f.
		 * <p>Force input file format. The format is normally auto detected for input files, so this option is not needed in most cases. </p>
		 * @default null which ommits it from the params used 
		 */	
		public var format:String;
		/** 
		 * FFmpeg equivalent: -vcodec.
		 * <p>Set the video codec.</p>
		 * @default null which ommits it from the params used 
		 */	
		public var videoCodec:String;
		/** 
		 * FFmpeg equivalent: -acodec.
		 * <p>Set the audio codec.</p>
		 * @default null which ommits it from the params used 
		 */	
		public var audioCodec:String;
		/** 
		 * FFmpeg equivalent: -i.
		 * <p>input file name. </p>
		 */	
		public var uri:String;
		/** 
		 * FFmpeg equivalent: -stream_loop.
		 * <p>Set number of times input stream shall be looped. Loop 0 means no loop, loop -1 means infinite loop.</p>
		 * @default 0
		 */	
		public var streamLoop:uint = 0;
		/** 
		 * FFmpeg equivalent: -t.
		 * <p>Limit the duration of data read from the input file. </p>
		 * @default -1.0
		 */	
		public var duration:Number = -1.0;
		/** 
		 * FFmpeg equivalent: -ss.
		 * <p>Seeks in this input file to position. Note that in most formats it is not possible to seek exactly, 
		 * so ffmpeg will seek to the closest seek point before position. 
		 * When transcoding and -accurate_seek is enabled (the default), this extra segment between the seek 
		 * point and position will be decoded and discarded. When doing stream copy or when -noaccurate_seek is used, it will be preserved. </p>
		 * @default 0.0
		 */	
		public var startTime:Number = 0.0;
		/** 
		 * FFmpeg equivalent: -itsoffset.
		 * <p>Set the input time offset. </p>
		 * <p>The offset is added to the timestamps of the input files. Specifying a positive offset means 
		 * that the corresponding streams are delayed by the time duration specified in offset.</p>
		 * @default 0.0
		 */	
		
		public var inputTimeOffset:Number = 0.0;
		/** 
		 * FFmpeg equivalent: -re.
		 * <p>Read input at native frame rate. Mainly used to simulate a grab device, or live input stream (e.g. when reading from a file). 
		 * Should not be used with actual grab devices or live input streams (where it can cause packet loss). 
		 * By default ffmpeg attempts to read the input(s) as fast as possible. This option will slow down the reading of the input(s) to the native frame rate of the input(s). 
		 * It is useful for real-time output (e.g. live streaming). </p>
		 * @default false
		 */
		public var realtime:Boolean = false;
		/** 
		 * FFmpeg equivalent: -pix_fmt.
		 * <p>Set pixel format. Use <code>getPixelFormats()</code> to show all the supported pixel formats. If the selected pixel format can not be selected, 
		 * ffmpeg will print a warning and select the best pixel format supported by the encoder. If pix_fmt is prefixed by a +, 
		 * ffmpeg will exit with an error if the requested pixel format can not be selected, and automatic conversions inside filtergraphs 
		 * are disabled. If pix_fmt is a single +, ffmpeg selects the same pixel format as the input (or graph output) and automatic conversions are disabled. </p>
		 */	
		public var pixelFormat:String;
		/** 
		 * FFmpeg equivalent: -r.
		 * <p>Set the input frame rate in frames per second. </p>
		 * @default 0.0 which ommits it from the params used 
		 */	
		public var frameRate:Number = 0.0;
		/** 
		 * FFmpeg equivalent: -s.
		 * <p>Specify the size of the sourced video, it may be a string of the form widthxheight, or the name of a size abbreviation.</p>
		 * @default null which ommits it from the params used 
		 */	
		public var size:String;
		/** 
		 * FFmpeg equivalent: -playlist.
		 * <p>Specify the playlist of Bluray or DVD.</p>
		 * @default null which ommits it from the params used 
		 */	
		public var playlist:int = -1;
		/** 
		 * FFmpeg equivalent: -hwaccel.
		 * <p>Use hardware acceleration to decode the matching stream(s). The allowed values of hwaccel are:</p>
		 * <ul>
		 * <li>none
		 * Do not use any hardware acceleration (the default).</li>
		 * <li>auto
		 * Automatically select the hardware acceleration method.</li>
		 * <li>vda
		 * Use Apple VDA hardware acceleration.</li>
		 * <li>vdpau
		 * Use VDPAU (Video Decode and Presentation API for Unix) hardware acceleration.</li>
		 * <li>dxva2
		 * Use DXVA2 (DirectX Video Acceleration) hardware acceleration.</li>
		 * <li>qsv
		 * Use the Intel QuickSync Video acceleration for video transcoding. </li>
		 * </ul>
		 * @default null which ommits it from the params used 
		 */	
		public var hardwareAcceleration:String;
		/** 
		 * FFmpeg equivalent: -threads.
		 * <p>Number of threads to use.</p>
		 * @default 0 which ommits it from the params used 
		 */	
		public var threads:uint = 0;	
		/** 
		 * This method is omitted from the output. * * @private 
		 */
		public var extraOptions:Vector.<*>; //eg avfoundation
		/** 
		 * The InputOptions class is a container class for input parameters.
		 * <p>An instance of this class should be passed to InputStream.addInput() when specifying input streams</p>
		 * @example The following code shows how:
		 * <listing version="3.0">
var inputOptions = new InputOptions();
inputOptions.uri = "https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4";
InputStream.addInput(inputOptions);
		 </listing>
		 */ 
		public function InputOptions(){}
		/** 
		 * Use this method to add additional parameters not available from the provided set
		 * <p>See the AVFoundationOptions class as an example.</p>
		 */	
		public function addExtraOptions(extra:*):void {
			if(extraOptions == null)
				extraOptions = new Vector.<*>;
			extraOptions.push(extra);
		}
		
	}
	
	
}