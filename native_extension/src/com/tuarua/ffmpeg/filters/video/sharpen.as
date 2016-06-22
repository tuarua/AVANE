package com.tuarua.ffmpeg.filters.video {
	public function sharpen(lumaMatrixX:int=5,lumaMatrixY:int=5,lumaAmount:Number=1.0,chromaMatrixX:int=5,chromaMatrixY:int=5,chromaAmount:Number=0.0):String {
		return "unsharp="+lumaMatrixX.toString()+":"+lumaMatrixY.toString()+":"+lumaAmount.toString()+":"+chromaMatrixX.toString()+":"+chromaMatrixY.toString()+":"+chromaAmount.toString();
	}
}