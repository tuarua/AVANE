package com.tuarua.ffprobe {
	[RemoteClass(alias="com.tuarua.ffprobe.Format")]//rename to FormatContext
	public class Format extends Object {
		public var filename:String;
		public var numStreams:int;
		public var numPrograms:int;
		public var formatName:String;
		public var formatLongName:String;
		public var startTime:Number;
		public var duration:Number;
		public var size:int; //bytes
		public var bitRate:int;
		public var probeScore:int;
		public var tags:Object;
		public function Format(){
			
		}
	}
}