package com.tuarua.ffmpeg {
	[RemoteClass(alias="com.tuarua.ffmpeg.X264Options")]
	public class X264Options extends Object {
		public var preset:String;
		public var profile:String;
		public var level:String;
		public var tune:String;
		public function X264Options(){}
		/** 
		 * This method is omitted from the output. * * @private 
		 */
		public function getAsVector():Vector.<Object> {
			var ret:Vector.<Object> = new Vector.<Object>;
			if(preset && preset.length > 0)
				ret.push({"key":"preset","value":preset});
			if(profile && profile.length > 0)
				ret.push({"key":"profile","value":profile});
			if(level && level.length > 0)
				ret.push({"key":"level","value":level});
			if(tune && tune.length > 0)
				ret.push({"key":"tune","value":tune});
			return ret;
		}
	}
}