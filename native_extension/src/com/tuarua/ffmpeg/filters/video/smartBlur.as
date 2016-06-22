package com.tuarua.ffmpeg.filters.video {
	public function smartBlur(lumaRadius:Number,lumaStrength:Number,lumaThreashold:int,chromaRadius:Number=null,chromaStrength:Number=null,chromaThreashold:int=null):String {
		var arr:Array = new Array();
		arr.push(lumaRadius);
		arr.push(lumaStrength);
		arr.push(lumaThreashold);
		if(chromaRadius)
			arr.push(chromaRadius);
		if(chromaStrength)
			arr.push(chromaStrength);
		if(chromaThreashold)
			arr.push(chromaThreashold);
		return "smartblur="+arr.join(":");
	}
}