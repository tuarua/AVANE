package com.tuarua.ffprobe {
	[RemoteClass(alias="com.tuarua.ffprobe.Stream")]
	public class Stream extends Object {
		//Common
		public var index:int;
		public var id:String;
		public var codecName:String;
		public var codecLongName:String;
		public var profile:String;
		public var codecType:String;
		public var codecTimeBase:String;
		public var codecTagString:String;
		public var codecTag:int;
		
		public var duration:Number;
		public var durationTimestamp:Number;
		
		public var realFrameRate:Number;
		public var averageFrameRate:Number;
		public var timeBase:String;
		
		public var startPTS:Number;
		public var startTime:Number;
		
		public var bitRate:Number;
		public var maxBitRate:Number;
		public var bitsPerRawSample:Number;
		public var numFrames:Number;
		public var tags:Object;
		public var disposition:Vector.<Object>; //TODO create Disposition Object
	}
}