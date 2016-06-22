package com.tuarua.ffmpeg {
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.LocaleID;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;

	public class Logger{
		public static var dispatcher:EventDispatcher = new EventDispatcher();
		private static var _enableLogToTrace:Boolean = true;
		private static var _enablelogToTextField:Boolean = false;
		private static var _enableLogToFile:Boolean = false;
		private static var _textField:TextField = new TextField();
		private static var ss:StyleSheet = new StyleSheet();
		private static var stream:FileStream;
		private static var _inited:Boolean;
		private static var timestamp:Date;
		private static var _logFileDirectory:File = File.desktopDirectory;
		public static function init(width:int,height:int):void {
			var debugStyle:Object = new Object();
			debugStyle.color = "#24C727";
			var verboseStyle:Object = new Object();
			verboseStyle.color = "#F5F516";
			var warningStyle:Object = new Object();
			warningStyle.color = "#FFBE0D";
			var errorStyle:Object = new Object();
			errorStyle.color = "#FA113C";
			var fatalStyle:Object = new Object();
			fatalStyle.color = "#FA113C";
			var panicStyle:Object = new Object();
			panicStyle.color = "#FA113C";
			
			ss.setStyle("p", {fontSize:"12",color:"#D8D8D8",fontFamily:"Consolas"});
			//ss.setStyle("p", {fontSize:"13",color:"#D8D8D8",fontFamily:firaSansRegularFont.fontName});
			
			ss.setStyle(".debug", debugStyle);
			ss.setStyle(".warning", warningStyle);
			ss.setStyle(".verbose", verboseStyle);
			ss.setStyle(".warning", warningStyle);
			ss.setStyle(".error", errorStyle);
			ss.setStyle(".fatal", fatalStyle);
			ss.setStyle(".panic", panicStyle);
			
			_textField = new TextField();
			_textField.styleSheet = ss;
			_textField.background = true;
			_textField.backgroundColor = 0x010101;
			_textField.width = width;
			_textField.height = height;
			_textField.multiline = true;
			_textField.wordWrap = true;
			_textField.selectable = true;
			_textField.embedFonts = false;
			_textField.antiAliasType = AntiAliasType.NORMAL;
			//_textField.sharpness = -100;
			_textField.htmlText = "";
			
			_inited = true;
			
		}
		
		public static function logToTrace(value:String):void {
			if(_enableLogToTrace)
				trace(value);
			
		}
		public static function logToTextField(value:String):void {
			if(_enablelogToTextField)
				_textField.htmlText += value;
			_textField.scrollV = _textField.numLines;
		}
		public static function logToFile(value:String):void {
			if(_enableLogToFile && stream){
				timestamp = new Date();
				stream.writeUTFBytes(timestamp.getHours().toString()+":"+timestamp.getMinutes().toString()+":"+timestamp.getSeconds().toString()+"."+timestamp.getMilliseconds().toString()+" - "+value+String.fromCharCode(13));
			}
		}
		
		public static function get enableLogToTrace():Boolean {
			return _enableLogToTrace;
		}
		public static function set enableLogToTrace(value:Boolean):void {
			_enableLogToTrace = value;
		}
		public static function get enableLogToTextField():Boolean {
			return _enablelogToTextField;
		}
		public static function set enableLogToTextField(value:Boolean):void {
			_enablelogToTextField = value;
		}
		public static function get enableLogToFile():Boolean {
			return _enableLogToFile;
		}
		public static function set enableLogToFile(value:Boolean):void {
			_enableLogToFile = value;
			if(_enableLogToFile){
				var file:File = _logFileDirectory.resolvePath("avane-"+unixToDate(new Date().getTime()/1000)+".log"); ;
				stream = new FileStream();
				stream.open(file, FileMode.WRITE);
			}else if(stream){
				closeLogStream();
			}
		}
		public static function finish():void {
			if(stream)
				closeLogStream();
		}
		private static function unixToDate(_val:uint):String {
			var d:Date = new Date(_val*1000);
			var dtf:DateTimeFormatter = new DateTimeFormatter(LocaleID.DEFAULT);
			dtf.setDateTimePattern("yMMd-HHmmss");
			return dtf.format(d);
		}
		private static function closeLogStream():void {
			if(stream) {
				stream.close();
				stream = null;
			}
		}
		public static function get inited():Boolean {
			return _inited;
		}

		public static function set inited(value:Boolean):void {
			_inited = value;
		}
		public static function get textField():TextField {
			return _textField;
		}
		public static function set logFileDirectory(value:File):void {
			_logFileDirectory = value;
		}

	}
}