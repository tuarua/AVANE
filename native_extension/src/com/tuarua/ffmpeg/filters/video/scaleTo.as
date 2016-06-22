package com.tuarua.ffmpeg.filters.video {
	
	public function scaleTo(w:int,h:int=-1):String {
		var ret:String;
		ret = (h > -1) ? "scale="+w+":"+h : "scale="+w+":-1";
		return ret;
	}
}