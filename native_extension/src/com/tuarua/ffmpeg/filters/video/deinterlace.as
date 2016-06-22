package com.tuarua.ffmpeg.filters.video {
	public function deinterlace(mode:int=0,parity:int=-1,auto:int=0):String {
		return "yadif="+mode.toString()+":"+parity.toString()+":"+auto.toString()+"";
	}
}