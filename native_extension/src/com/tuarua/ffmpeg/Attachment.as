package com.tuarua.ffmpeg {
	import com.tuarua.ffmpeg.constants.MimeTypes;
	public class Attachment extends Object {
		public var fileName:String;
		public function Attachment(){}
		//public var mimeType:String = "auto";
		//-attach DejaVuSans.ttf -metadata:s:2 mimetype=application/x-truetype-font
		public function getMimeType():String {
			return MimeTypes.getValue(fileName.substring(fileName.lastIndexOf(".")+1, fileName.length))
		}
	}
}