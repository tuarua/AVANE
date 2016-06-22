package com.tuarua.ffmpeg {
	[RemoteClass(alias="com.tuarua.ffmpeg.X265AdvancedOptions")]
	public class X265AdvancedOptions extends Object {
		public var type:String = "x265-params";
		public var profile:String;
		public var tune:String;
		
		public function getAsString():String {
			var arr:Array = new Array();
			if(profile)
				arr.push("profile="+profile);
			if(tune)
				arr.push("tune="+tune);
			return arr.join(":");
		}
	}
	
}
//ffmpeg -i "<any random video>" -an -c:v libx265 -x265-params 'aq-mode=0:invalidkey=:keyint=4:min-keyint=30:anotherinvalidkey=value:rd=5' test.mkv
//-x265-params crf=26:psy-rd=1