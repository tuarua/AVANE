package com.tuarua.ffmpeg.gets {
	[RemoteClass(alias="com.tuarua.ffmpeg.gets.Encoder")]
	public class Encoder {
		public var name:String;
		public var nameLong:String;
		public var isVideo:Boolean;
		public var isAudio:Boolean;
		public var isSubtitles:Boolean;
		public var hasFrameLevelMultiThreading:Boolean;
		public var hasSliceLevelMultiThreading:Boolean;
		public var isExperimental:Boolean;
		public var supportsDrawHorizBand:Boolean;
		public var supportsDirectRendering:Boolean;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Encoder(){}
	}
}