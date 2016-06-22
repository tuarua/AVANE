package views.client {
	import com.tuarua.ffmpeg.events.FFmpegEvent;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import views.CircularLoader;
	import utils.TextUtils;
	import utils.TimeUtils;

	public class EncodingScreen extends Sprite {
		private var circularLoader:CircularLoader;
		private var speedLbl:TextField;
		private var bitrateLbl:TextField;
		private var timeLbl:TextField;
		private var sizeLbl:TextField;
		private var frameLbl:TextField;
		private var fpsLbl:TextField;
		
		private var speedTxt:TextField;
		private var bitrateTxt:TextField;
		private var timeTxt:TextField;
		private var sizeTxt:TextField;
		private var frameTxt:TextField;
		private var fpsTxt:TextField;
		
		private var _totalTime:Number;
		private var lblHolder:Sprite = new Sprite();
		private var txtHolder:Sprite = new Sprite();
		public function EncodingScreen() {
			super();
			this.visible = false;
			circularLoader = new CircularLoader();
			circularLoader.x = 280;
			circularLoader.y = 6;
			circularLoader.visible = true;
			speedLbl = new TextField(120,32,"Speed:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			bitrateLbl = new TextField(120,32,"Bitrate:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			timeLbl = new TextField(120,32,"Time:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			sizeLbl = new TextField(120,32,"Size:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			frameLbl = new TextField(120,32,"Frame:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			fpsLbl = new TextField(120,32,"Fps:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			speedTxt = new TextField(120,32,"", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			bitrateTxt = new TextField(120,32,"", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			timeTxt = new TextField(120,32,"", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			sizeTxt = new TextField(120,32,"", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			frameTxt = new TextField(120,32,"", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			fpsTxt = new TextField(120,32,"", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			fpsLbl.vAlign = timeLbl.vAlign = sizeLbl.vAlign = frameLbl.vAlign = speedLbl.vAlign = bitrateLbl.vAlign = VAlign.TOP;
			fpsLbl.hAlign = timeLbl.hAlign = sizeLbl.hAlign = frameLbl.hAlign = speedLbl.hAlign = bitrateLbl.hAlign = HAlign.LEFT;
			fpsLbl.touchable = timeLbl.touchable = sizeLbl.touchable = frameLbl.touchable = speedLbl.touchable = bitrateLbl.touchable = false;
			fpsLbl.batchable = timeLbl.batchable = sizeLbl.batchable = frameLbl.batchable = speedLbl.batchable = bitrateLbl.batchable = true;
			
			fpsTxt.vAlign = timeTxt.vAlign = sizeTxt.vAlign = frameTxt.vAlign = speedTxt.vAlign = bitrateTxt.vAlign = VAlign.TOP;
			fpsTxt.hAlign = timeTxt.hAlign = sizeTxt.hAlign = frameTxt.hAlign = speedTxt.hAlign = bitrateTxt.hAlign = HAlign.LEFT;
			fpsTxt.touchable = timeTxt.touchable = sizeTxt.touchable = frameTxt.touchable = speedTxt.touchable = bitrateTxt.touchable = false;
			fpsTxt.batchable = timeTxt.batchable = sizeTxt.batchable = frameTxt.batchable = speedTxt.batchable = bitrateTxt.batchable = true;
			
			timeTxt.y = timeLbl.y = 0;
			frameTxt.y = frameLbl.y = 20;
			sizeTxt.y = sizeLbl.y = 40;
			bitrateTxt.y = bitrateLbl.y = 60;
			speedTxt.y = speedLbl.y = 80;
			fpsTxt.y = fpsLbl.y = 100;
			
			lblHolder.addChild(timeLbl);
			lblHolder.addChild(frameLbl);
			lblHolder.addChild(sizeLbl);
			lblHolder.addChild(bitrateLbl);
			lblHolder.addChild(speedLbl);
			lblHolder.addChild(fpsLbl);
			
			txtHolder.addChild(timeTxt);
			txtHolder.addChild(frameTxt);
			txtHolder.addChild(sizeTxt);
			txtHolder.addChild(bitrateTxt);
			txtHolder.addChild(speedTxt);
			txtHolder.addChild(fpsTxt);
			txtHolder.x = 80;
			addChild(circularLoader);
			
			addChild(lblHolder);
			
			addChild(txtHolder);
			
			lblHolder.flatten();
		}
		public function show(value:Boolean):void {
			this.visible = value;
		}
		public function clear():void {
			
		}
		public function onProgress(event:FFmpegEvent):void {
			timeTxt.text = TimeUtils.secsToTimeCode((event.params.secs) + (event.params.us/100)) + " / "+TimeUtils.secsToTimeCode(_totalTime);
			frameTxt.text = event.params.frame.toString();
			sizeTxt.text = TextUtils.bytesToString(event.params.size*1024);
			bitrateTxt.text = event.params.bitrate.toFixed(2)+" Kbps";
			speedTxt.text = event.params.speed.toFixed(2)+"x";
			fpsTxt.text = event.params.fps.toFixed(2);
			/*
			trace("speed",event.params.speed.toFixed(2));
			trace("bitrate",event.params.bitrate.toFixed(2));
			trace("time",(event.params.secs) + (event.params.us/100));
			trace("size",Math.round(event.params.size));
			trace("fps",event.params.fps);
			trace("frame",event.params.frame);
			trace("percent",((event.params.secs) + (event.params.us/100)) / _totalTime);
			*/
			circularLoader.update(((event.params.secs) + (event.params.us/100)) / _totalTime);
		}

		
		public function set totalTime(value:Number):void {
			_totalTime = value;
		}

	}
}