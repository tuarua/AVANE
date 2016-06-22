package com.tuarua.ffprobe.events {
	import flash.events.Event;
	public class ProbeEvent extends Event {
		public static const ON_PROBE_INFO:String = "onProbeInfo";
		public static const NO_PROBE_INFO:String = "noProbeInfo";
		public var params:Object;
		public function ProbeEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
		public override function clone():Event {
			return new ProbeEvent(type, this.params, bubbles, cancelable);
		}	
		public override function toString():String {
			return formatToString("ProbeEvent", "params", "type", "bubbles", "cancelable");
		}
	}
}