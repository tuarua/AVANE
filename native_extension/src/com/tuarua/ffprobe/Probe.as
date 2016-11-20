package com.tuarua.ffprobe {
	[RemoteClass(alias="com.tuarua.ffprobe.Probe")]
	public class Probe extends Object {
		public var format:Format;
		public var videoStreams:Vector.<VideoStream>;
		public var audioStreams:Vector.<AudioStream>;
		public var subtitleStreams:Vector.<SubtitleStream>;
		public function Probe(){
			
		}
	}
}