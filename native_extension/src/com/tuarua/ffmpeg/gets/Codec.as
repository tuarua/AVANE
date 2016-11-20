package com.tuarua.ffmpeg.gets {
	[RemoteClass(alias="com.tuarua.ffmpeg.gets.Codec")]
	public class Codec {
		public var name:String;
		public var nameLong:String;
		public var hasDecoder:Boolean;
		public var hasEncoder:Boolean;
		public var isVideo:Boolean;
		public var isAudio:Boolean;
		public var isSubtitles:Boolean;
		public var isLossy:Boolean;
		public var isLossless:Boolean;
		public var isIntraFrameOnly:Boolean;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Codec(){}
	}
}