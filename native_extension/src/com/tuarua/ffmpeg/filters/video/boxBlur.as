package com.tuarua.ffmpeg.filters.video {
		public function boxBlur(lumaRadius:String,lumaPower:String,chromaRadius:String=null,chromaPower:String=null,alphaRadius:String=null,alphaPower:String=null):String {
			var arr:Array = new Array();
			arr.push(lumaRadius);
			arr.push(lumaPower);
			if(chromaRadius)
				arr.push(chromaRadius);
			if(chromaPower)
				arr.push(chromaPower);
			if(alphaRadius)
				arr.push(alphaRadius);
			if(alphaPower)
				arr.push(alphaPower);
			return "boxblur="+arr.join(":");
		}
}