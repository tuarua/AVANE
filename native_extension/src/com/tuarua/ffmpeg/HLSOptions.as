package com.tuarua.ffmpeg {
	public class HLSOptions extends Object {
		public var time:int = 2;
		public var listSize:int = 5;
		public var wrap:int = 0;
		public var startNumber:Number = 0.0;
		public var allowCache:Boolean = true;
		public var baseUrl:String;
		public var segmentFileName:String;//'file%03d.ts'
		public var useLocalTime:Boolean = false;
		public var useLocalTimeMkdir:Boolean = false;
		public var keyInfoFile:String;
		public var singleFile:Boolean = false;
		public var deleteSegments:Boolean = false;
		public var live:Boolean = false;
		public function getAsVector():Vector.<Object> {
			var ret:Vector.<Object> = new Vector.<Object>;
			
			if(time != 2)
				ret.push({"key":"hls_time","value":time.toString()});
			if(listSize != 5)
				ret.push({"key":"hls_list_size","value":listSize.toString()});
			
			if(wrap > 0)
				ret.push({"key":"hls_wrap","value":wrap.toString()});
			
			if(startNumber > 0)
				ret.push({"key":"start_number","value":startNumber.toString()});
			if(baseUrl)
				ret.push({"key":"hls_base_url","value":baseUrl});
			if(allowCache)
				ret.push({"key":"hls_allow_cache","value":(allowCache) ? "1" : "0"});
			if(segmentFileName)
				ret.push({"key":"hls_segment_filename","value":segmentFileName});
			if(useLocalTime)
				ret.push({"key":"use_localtime","value":(useLocalTime) ? "1" : "0"});
			if(useLocalTimeMkdir)
				ret.push({"key":"use_localtime_mkdir","value":(useLocalTimeMkdir) ? "1" : "0"});
			if(keyInfoFile)
				ret.push({"key":"hls_key_info_file","value":keyInfoFile});
			if(singleFile)
				ret.push({"key":"hls_flags","value":"single_file"});
			if(deleteSegments)
				ret.push({"key":"hls_flags","value":"delete_segments"});
			
			ret.push({"key":"hls_playlist_type","value":(live) ? "event" : "vod"});
			
			return ret;
		}
	}
}