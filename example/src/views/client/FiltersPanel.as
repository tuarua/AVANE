package views.client {
	import com.tuarua.ffmpeg.constants.X264Preset;
	
	import events.FormEvent;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.Align;
	
	import views.forms.DropDown;
	
	public class FiltersPanel extends Sprite {
		private var denoiseDrop:DropDown;
		private var selectedDenoise:Array;
		private var _denoiseDataList:Vector.<Object> = new Vector.<Object>;
		private var denoiseLbl:TextField = new TextField(120,32,"Denoise:");
		public function FiltersPanel() {
			super();
			
			denoiseLbl.format.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,Align.LEFT,Align.TOP);
			denoiseLbl.touchable = false;
			denoiseLbl.batchable = true;
			
			denoiseLbl.x = 42;
			denoiseLbl.y = 40;
			
			_denoiseDataList.push({value:new Array(),label:"None"});
			_denoiseDataList.push({value:new Array(2,1,2,3),label:"Weak"});
			_denoiseDataList.push({value:new Array(3,2,2,3),label:"Medium"});
			_denoiseDataList.push({value:new Array(7,7,5,5),label:"Strong"});
			
			denoiseDrop = new DropDown(120,_denoiseDataList);
			denoiseDrop.addEventListener(FormEvent.CHANGE,onFormChange);
			denoiseDrop.x = 120;
			denoiseDrop.y = 37;
			
			addChild(denoiseDrop);
			addChild(denoiseLbl);
		}
		private function onFormChange(event:FormEvent):void {
			var test:int;
			switch(event.currentTarget){
				case denoiseDrop:
					selectedDenoise = event.params.value;
					break;
			}
		}
		public function getDenoise():Array {
			return selectedDenoise;
		}
		
		public function freeze():void {
		}
		public function unfreeze():void {
		}
		
	}
}