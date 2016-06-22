package com.tuarua.ffmpeg {
	[RemoteClass(alias="com.tuarua.ffmpeg.X265Options")]
	public class X265Options extends Object{
		public var preset:String;
		//public var profile:String;//these go into Advanced
		//public var tune:String;//these go into Advanced
		
		public function getAsVector():Vector.<Object> {
			var ret:Vector.<Object> = new Vector.<Object>;
			if(preset && preset.length > 0)
				ret.push({"key":"preset","value":preset});
			return ret;
		}
		
	}

}