package com.tuarua.ffmpeg.filters.video {
	public function to16x9():String {
		return "pad=ih*16/9:ih:(ow-iw)/2:(oh-ih)/2";
	}
}