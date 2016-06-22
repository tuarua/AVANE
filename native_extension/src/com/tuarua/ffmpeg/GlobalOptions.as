package com.tuarua.ffmpeg {
	[RemoteClass(alias="com.tuarua.ffmpeg.GlobalOptions")]
	public class GlobalOptions extends Object {
		public static var overwriteOutputFiles:Boolean = true;
		public static var ignoreUnknown:Boolean = false;
		//public static var maxAllocBytes:int = -1; //what is default ?
		//public static var volume:int = 256;
		public static var maxErrorRate:Number = 0.0;
		public static var copyUnknown:Boolean = false;
		public static var timeLimit:int = -1;
		public static var vsync:String = "-1"; //-1 auto, 0 = passthrough,1 = cfr,2 = vfr, drop
		public static var fDropThreshold:Number = -1.1; //doesn't like frameDropThreadhold
		public static var copyTs:Boolean = false;
		public static var startAtZero:Boolean = false;
		public static var copyTb:int = -1; // 0 is decoder, 1 is demuxer

		/*
		public static function getOvrwrtFles():Boolean {
			return _overwriteOutputFiles;
		}
		public static function set overwriteOutputFiles(value:Boolean):void {
			_overwriteOutputFiles = value;
		}
		public static function getIgnrUnknwn():Boolean {
			return _ignoreUnknown;
		}
		public static function set ignoreUnknown(value:Boolean):void {
			_ignoreUnknown = value;
		}
		public static function getMxErrRte():Number {
			return _maxErrorRate;
		}
		public static function set maxErrorRate(value:Number):void {
			_maxErrorRate = value;
		}
		public static function getCopyUnknwn():Boolean {
			return _copyUnknown;
		}
		public static function set copyUnknown(value:Boolean):void {
			_copyUnknown = value;
		}
		public static function getTimeLimit():int {
			return _timeLimit;
		}
		public static function set timeLimit(value:int):void {
			_timeLimit = value;
		}
		public static function getVsync():String{
			return _vsync;
		}
		public static function set vsync(value:String):void{
			_vsync = value;
		}
		public static function getfDrpThrsh():Number {
			return _fDropThreshold;
		}
		public static function set fDropThreshold(value:Number):void {
			_fDropThreshold = value;
		}
		public static function getCopyTs():Boolean {
			return _copyTs;
		}
		public static function set copyTs(value:Boolean):void {
			_copyTs = value;
		}
		public static function getStrtAtZro():Boolean {
			return _startAtZero;
		}
		public static function set startAtZero(value:Boolean):void {
			_startAtZero = value;
		}
		public static function getCopyTb():int {
			return _copyTb;
		}
		public static function set copyTb(value:int):void {
			_copyTb = value;
		}
		*/
	}
}







/*

Global options (affect whole program instead of just one file:
NA -loglevel loglevel  set logging level
NA -v loglevel         set logging level
?? -report             generate a report
DONE -max_alloc bytes    set maximum size of a single allocated block
DONE -y                  overwrite output files
DONE -n                  never overwrite output files
DONE -ignore_unknown     Ignore unknown stream types
NA -stats              print progress report during encoding
DONE -max_error_rate ratio of errors (0.0: no errors, 1.0: 100% error  maximum error rate
?? deprecated -bits_per_raw_sample number  set the number of bits per raw sample
DONE -vol volume         change audio volume (256=normal)

Advanced global options:
NA -cpuflags flags     force specific cpu flags
NA -hide_banner hide_banner  do not show program banner
DONE -copy_unknown       Copy unknown stream types
?? -benchmark          add timings for benchmarking
?? -benchmark_all      add timings for each task
?? -progress url       write program-readable progress information
NA -stdin              enable or disable interaction on standard input
DONE -timelimit limit    set max runtime in seconds
NA -dump               dump each input packet
NA -hex                when dumping packets, also dump the payload
DONE -vsync              video sync method
DONE -frame_drop_threshold   frame drop threshold
?? Deprecated -async              audio sync method
?? -adrift_threshold threshold  audio drift threshold
DONE -copyts             copy timestamps
DONE -start_at_zero      shift input timestamps to start at 0 when using copyts
DONE -copytb mode        copy input stream time base when stream copying
-dts_delta_threshold threshold  timestamp discontinuity delta threshold
-dts_error_threshold threshold  timestamp error delta threshold
NA -xerror error       exit on error
NA -abort_on flags     abort on the specified condition flags
-filter_complex graph_description  create a complex filtergraph
NA -lavfi graph_description  create a complex filtergraph
-filter_complex_script filename  read complex filtergraph description from a file
?? -debug_ts           print timestamp debugging info
?? -psnr               calculate PSNR of compressed frames
NA -vstats             dump video coding statistics to file
NA -vstats_file file   dump video coding statistics to file
NA -qphist             show QP histogram
-override_ffserver   override the options from ffserver
NA -sdp_file file      specify a file in which to print sdp information
*/