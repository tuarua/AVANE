package com.tuarua.ffprobe {
	[RemoteClass(alias="com.tuarua.ffprobe.VideoStream")]
	public class VideoStream extends Stream {
		public var width:int;
		public var height:int;
		public var codedWidth:int;
		public var codedHeight:int;
		public var hasBframes:int;
		public var sampleAspectRatio:String;
		public var displayAspectRatio:String;
		public var pixelFormat:String;
		public var level:int;
		public var colorRange:String;
		public var colorSpace:String;
		public var colorTransfer:String;
		public var colorPrimaries:String;
		public var chromaLocation:String;
		public var timecode:String;
		public var refs:int;
		public function VideoStream(){}
	}
}