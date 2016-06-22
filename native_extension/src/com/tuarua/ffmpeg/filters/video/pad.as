package com.tuarua.ffmpeg.filters.video {
	public function pad(w:int,h:int,x:int,y:int,color="black"):String {
		return "pad=width="+w+":height="+h+":x="+x+":y="+y+":color="+color;
	}
}