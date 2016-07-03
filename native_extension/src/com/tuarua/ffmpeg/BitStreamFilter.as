package com.tuarua.ffmpeg {
	public class BitStreamFilter extends Object {
		public var type:String;//v or a
		public var value:String;//eg aac_adtstoasc
		public function BitStreamFilter(_type:String=null,_value:String=null) {
			super();
			type = _type;
			value = _value;
		}
	}
}