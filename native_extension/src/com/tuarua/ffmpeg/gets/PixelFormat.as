package com.tuarua.ffmpeg.gets {
	[RemoteClass(alias="com.tuarua.ffmpeg.gets.PixelFormat")]
	public class PixelFormat {
		public var name:String;
		public var isInput:Boolean;
		public var isOutput:Boolean;
		public var isHardwareAccelerated:Boolean;
		public var isPalleted:Boolean;
		public var isBitStream:Boolean;
		public var numComponents:int;
		public var bitsPerPixel:int;
	}
}