package com.tuarua.ffmpeg {
	public class HLSOptions extends Object {
		public var time:int = 2;
		public var listSize:int = 5;
		public var wrap:int = 0;
		public var startNumber:Number = 0.0;
		public var allowCache:Boolean = true;
		public var baseUrl:String;
		public var segmentFileName:String;//'file%03d.ts'
		public var useLocalTime:Boolean = false;
		public var useLocalTimeMkdir:Boolean = false;
		public var keyInfoFile:String;
		public var singleFile:Boolean = false;
		public var deleteSegments:Boolean = false;
		public var live:Boolean = false;
		public function HLSOptions() {
			
		}
		public function getAsString():String {
			var arr:Array = new Array();
			return arr.join(":");
		}
	}
}