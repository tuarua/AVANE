package com.tuarua.ffmpeg {
	public class Overlay {
		private var _fileName:String;
		private var _x:int = 0;
		private var _y:int = 0;
		private var _inTime:Number = -1;
		private var _outTime:Number = -1;
		public function Overlay(fileName:String = null,x:int=0,y:int=0,inTime:int=-1,outTime:int=-1) {
			_fileName = fileName;
			_x = x;
			_y = y;
			_inTime = inTime;
			_outTime = outTime;
		}
		public function set fileName(value:String):void {
			_fileName = value;
		}
		public function get fileName():String {
			return _fileName;
		}

		public function get x():int {
			return _x;
		}

		public function set x(value:int):void {
			_x = value;
		}

		public function get y():int {
			return _y;
		}

		public function set y(value:int):void {
			_y = value;
		}

		public function get inTime():Number {
			return _inTime;
		}

		public function set inTime(value:Number):void {
			_inTime = value;
		}

		public function get outTime():Number {
			return _outTime;
		}

		public function set outTime(value:Number):void {
			_outTime = value;
		}


	}
}