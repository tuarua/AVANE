package com.tuarua.ffmpeg.filters.video {
	public function denoise(lumaSpatial:Number=4.0,chromaSpatial:Number=-1,lumaTemporal:Number=-1,chromaTemporal:Number=-1):String {
		var _chromaSpatial:Number;
		var _lumaTemporal:Number;
		var _chromaTemporal:Number;
		_chromaSpatial = (chromaSpatial > -1) ? chromaSpatial : (3.0*lumaSpatial)/4.0;
		_lumaTemporal = (lumaTemporal > -1) ? lumaTemporal : (6.0*lumaSpatial)/4.0;
		_chromaTemporal = (chromaTemporal > -1) ? chromaTemporal : _lumaTemporal*_chromaSpatial/lumaSpatial;
		return "hqdn3d="+lumaSpatial.toString()+":"+_chromaSpatial.toString()+":"+_lumaTemporal.toString()+":"+_chromaTemporal.toString();
	}
}