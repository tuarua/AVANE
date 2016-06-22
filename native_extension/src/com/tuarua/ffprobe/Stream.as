package com.tuarua.ffprobe {
	[RemoteClass(alias="com.tuarua.ffprobe.Stream")]
	public class Stream extends Object {
		//Common
		public var index:int;
		public var id:String;
		public var codecName:String;
		public var codecLongName:String;
		public var profile:String;
		public var codecType:String;
		public var codecTimeBase:String;
		public var codecTagString:String;
		public var codecTag:int;
		
		public var duration:Number;
		public var durationTimestamp:Number;
		
		public var realFrameRate:Number;
		public var averageFrameRate:Number;
		public var timeBase:String;
		
		public var startPTS:Number;
		public var startTime:Number;
		
		public var bitRate:Number;
		public var maxBitRate:Number;
		public var bitsPerRawSample:Number;
		public var numFrames:Number;
		public var tags:Object;
		public var disposition:Vector.<Object>; //TO DO create Disposition Object
	}
}

/*
"streams": [
{


"width": 1920,
"height": 1080,
"coded_width": 1920,
"coded_height": 1088,
"has_b_frames": 4,
"sample_aspect_ratio": "1:1",
"display_aspect_ratio": "16:9",


"pix_fmt": "yuv420p",
"level": 41,
"chroma_location": "left",
"refs": 4,
"is_avc": "true",
"nal_length_size": "4",
"r_frame_rate": "24000/1001",
"avg_frame_rate": "64755000/2700823",
"time_base": "1/90000",
"start_pts": 0,
"start_time": "0.000000",
"duration_ts": 16204938,
"duration": "180.054867",
"bit_rate": "24894141",
"bits_per_raw_sample": "8",
"nb_frames": "4317",
"disposition": {
"default": 1,
"dub": 0,
"original": 0,
"comment": 0,
"lyrics": 0,
"karaoke": 0,
"forced": 0,
"hearing_impaired": 0,
"visual_impaired": 0,
"clean_effects": 0,
"attached_pic": 0
},
"tags": {
"language": "und",
"handler_name": "VideoHandler"
}
},


{
"index": 1,
"codec_name": "aac",
"codec_long_name": "AAC (Advanced Audio Coding)",
"profile": "LC",
"codec_type": "audio",
"codec_time_base": "1/48000",
"codec_tag_string": "mp4a",
"codec_tag": "0x6134706d",
"sample_fmt": "fltp",
"sample_rate": "48000",
"channels": 2,
"channel_layout": "stereo",
"bits_per_sample": 0,
"r_frame_rate": "0/0",
"avg_frame_rate": "0/0",
"time_base": "1/48000",
"start_pts": -1024,
"start_time": "-0.021333",
"duration_ts": 8641024,
"duration": "180.021333",
"bit_rate": "267829",
"max_bit_rate": "448000",
"nb_frames": "8439",
"disposition": {
"default": 1,
"dub": 0,
"original": 0,
"comment": 0,
"lyrics": 0,
"karaoke": 0,
"forced": 0,
"hearing_impaired": 0,
"visual_impaired": 0,
"clean_effects": 0,
"attached_pic": 0
},
"tags": {
"language": "und",
"handler_name": "SoundHandler"
}
}
}
*/