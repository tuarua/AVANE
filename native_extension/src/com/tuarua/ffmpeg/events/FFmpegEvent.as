package com.tuarua.ffmpeg.events {
	import flash.events.Event;
	
	public class FFmpegEvent extends Event {
		public static const ON_ENCODE_START:String = "onEncodeStart";
		public static const ON_ENCODE_ERROR:String = "onEncodeError";
		public static const ON_ENCODE_FINISH:String = "onEncodeFinish";
		public static const ON_ENCODE_PROGRESS:String = "onEncodeProgress";
		public var params:Object;
		public function FFmpegEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
		public override function clone():Event {
			return new FFmpegEvent(type, this.params, bubbles, cancelable);
		}	
		public override function toString():String {
			return formatToString("FFmpegEvent", "params", "type", "bubbles", "cancelable");
		}
		
	}
}