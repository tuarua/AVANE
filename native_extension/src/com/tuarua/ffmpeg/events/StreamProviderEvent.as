package com.tuarua.ffmpeg.events {
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class StreamProviderEvent extends Event {
		public static const ON_STREAM_DATA:String = "onStreamData";
		public static const ON_STREAM_CLOSE:String = "onStreamClose";
		public var data:ByteArray;
		public function StreamProviderEvent(type:String, _ba:ByteArray=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.data = _ba;
		}
	}
}