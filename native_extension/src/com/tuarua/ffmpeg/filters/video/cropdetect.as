package com.tuarua.ffmpeg.filters.video {
	public function cropdetect(limit:int=24,round:int=16,reset:int=0):String {
		return "cropdetect="+limit.toString()+":"+round.toString()+":"+reset.toString();
	}
}