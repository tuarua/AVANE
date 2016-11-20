package com.tuarua.ffmpeg.filters.video {
	public function smartBlur(lumaRadius:Number,lumaStrength:Number,lumaThreashold:int,chromaRadius:Number=-1,chromaStrength:Number=-1,chromaThreashold:int=-1):String {
		var arr:Array = new Array();
		arr.push(lumaRadius);
		arr.push(lumaStrength);
		arr.push(lumaThreashold);
		if(chromaRadius > -1)
			arr.push(chromaRadius);
		if(chromaStrength > -1)
			arr.push(chromaStrength);
		if(chromaThreashold > -1)
			arr.push(chromaThreashold);
		return "smartblur="+arr.join(":");
	}
}