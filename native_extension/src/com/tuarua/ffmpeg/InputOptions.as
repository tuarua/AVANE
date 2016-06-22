package com.tuarua.ffmpeg {
	public class InputOptions extends Object {
		public var format:String;
		public var uri:String;
		public var streamLoop:uint = 0;
		public var duration:Number = -1.0;
		public var startTime:Number = 0.0;
		public var inputTimeOffset:Number = 0.0;
		public var realtime:Boolean = false;
		//public var pixelFormat:String;//need
		public var frameRate:int = 0;
		public var playlist:int = -1;
		//public var hardwareAcceleration:String;
		public var threads:uint = 0;
	}
	
}