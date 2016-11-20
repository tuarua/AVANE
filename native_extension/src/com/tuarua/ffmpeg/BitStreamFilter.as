package com.tuarua.ffmpeg {
	public class BitStreamFilter extends Object {
		/** 
		 * <p>Type of bsf, v or a</p>
		 */			
		public var type:String;
		/** 
		 * <p>eg aac_adtstoasc</p>
		 */	
		public var value:String;
		/**
		 * 
		 * @param _type "v" or "a"
		 * @param _value eg aac_adtstoasc
		 * 
		 */		
		public function BitStreamFilter(_type:String=null,_value:String=null) {
			super();
			type = _type;
			value = _value;
		}
	}
}