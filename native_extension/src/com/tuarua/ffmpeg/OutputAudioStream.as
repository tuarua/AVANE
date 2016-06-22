package com.tuarua.ffmpeg {
	public class OutputAudioStream extends Object {
		public var codec:String;
		public var samplerate:int = -1;
		public var bitrate:int = -1;
		public var sourceIndex:int = 0;
		public var channels:int = 2;
		public var frames:int = -1;
		public function OutputAudioStream() {
		}
	}
}