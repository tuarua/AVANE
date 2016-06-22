package com.tuarua.ffprobe {
	[RemoteClass(alias="com.tuarua.ffprobe.AudioStream")]
	public class AudioStream extends Stream {
		public var sampleFormat:String;
		public var sampleRate:int;
		public var channels:int;
		public var channelLayout:String;
		public var bitsPerSample:int;
	}
}