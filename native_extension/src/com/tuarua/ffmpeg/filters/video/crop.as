package com.tuarua.ffmpeg.filters.video {
	public function crop(outWidth:int,outHeight:int=-1,x:int=-1,y:int=-1,keepAspect:Boolean=false):String {//convert to strings to allow expressions
		var arr:Array = new Array();
		arr.push(outWidth);
		if(outHeight > -1)
			arr.push(outHeight);
		if(x > -1)
			arr.push(x);
		if(y > -1)
			arr.push(y);
		if(keepAspect)
			arr.push(1);
		return "crop="+arr.join(":");
	}
}