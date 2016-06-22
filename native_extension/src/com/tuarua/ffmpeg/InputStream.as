package com.tuarua.ffmpeg {
	[RemoteClass(alias="com.tuarua.ffmpeg.InputStream")]
	public class InputStream extends Object{
		public static var options:Vector.<InputOptions> = new Vector.<InputOptions>;
		public static function clear():void {
			if(options)
				options.splice(0, options.length); //this is how to clear a vector
		}
		public static function addInput(inputOptions:InputOptions):void {
			if(options == null)
				options = new Vector.<InputOptions>
			options.push(inputOptions);
		}
		public static function getOptions():Vector.<InputOptions>{
			return options;
		}
	}
}