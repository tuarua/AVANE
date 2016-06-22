package com.tuarua.ffmpeg {
	public class OutputVideoStream extends Object{
		public var codec:String;
		public var inputIndex:int = 0;
		public var sourceIndex:int = 0;
		public var bitrate:int = -1;
		public var crf:int = -1; //0-51
		public var qp:int = -1; //0-69
		public var frames:int = -1;
		public var pixelFormat:String;
		public var encoderOptions:* = null;
		public var advancedEncOpts:* = null;
	}
}