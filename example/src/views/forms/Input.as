package views.forms {
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	import events.FormEvent;
	
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import views.forms.NativeTextInput;
	
	public class Input extends Sprite {
		private var txtures:Scale9Textures;
		private var inputBG:Scale9Image;
		//private var w:int;
		private var nti:NativeTextInput;
		private var frozenText:TextField;
		private var isEnabled:Boolean = true;
		private var _password:Boolean = false;
		private var _type:String = TextFieldType.INPUT;
		private var _multiline:Boolean = false;
		public function Input(_w:int,_txt:String,_h:int=25) {
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE,onAddedToStage);
			//w = _w;
			
			txtures = new Scale9Textures(Assets.getAtlas().getTexture("input-bg"),new Rectangle(4,4,16,16));
			inputBG = new Scale9Image(txtures);
			inputBG.width = _w;
			inputBG.height = _h;
			
			inputBG.blendMode = BlendMode.NONE;
			inputBG.touchable = false;
			inputBG.flatten();
			frozenText = new TextField(_w,_h,_txt, "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			frozenText.x = 6;
			frozenText.y = 4;
			frozenText.vAlign = VAlign.TOP;
			frozenText.hAlign = HAlign.LEFT;
			frozenText.touchable = false;
			frozenText.batchable = true;
			frozenText.visible = false;
			nti = new NativeTextInput(_w-10,_txt,false,0xC0C0C0);
			nti.setHeight(_h);
			nti.addEventListener("CHANGE",onTextChange);
			addChild(inputBG);
			addChild(frozenText);
		}
		
		protected function onTextChange(event:flash.events.Event):void {
			frozenText.text = nti.input.text;
		}
		
		private function onAddedToStage(event:starling.events.Event):void {
			updatePosition();
			nti.addEventListener("CHANGE",changeHandler);
			Starling.current.nativeOverlay.addChild(nti);
		}
		protected function changeHandler(event:flash.events.Event):void {
			this.dispatchEvent(new FormEvent(FormEvent.CHANGE));
		}
		public function freeze():void {
			frozenText.visible = true;
			nti.show(false);
			updatePosition();
		}
		public function unfreeze():void {
			frozenText.visible = false;
			nti.show(true);
			updatePosition();
		}
		public function updatePosition():void {
			try{
				var pos:Point = this.parent.localToGlobal(new Point(this.x,this.y));
				var offsetY:int = 1;
				nti.x = pos.x + 5;
				nti.y = pos.y + offsetY;
			}catch(e:Error){
				
			}
		}
		public function enable(_b:Boolean):void {
			isEnabled = _b;
			inputBG.alpha = (_b) ? 1 : 0.25;
			nti.enable(_b);
		}

		public function set password(value:Boolean):void {
			nti.password = _password = value;
		}

		public function set type(value:String):void {
			nti.type = _type = value;
		}

		public function set multiline(value:Boolean):void {
			nti.multiline = _multiline = value;
		}
		public function set maxChars(value:uint):void {
			nti.maxChars = value;
		}
		public function set restrict(value:String):void {
			nti.restrict = value;
		}
		public function get text():String{
			return nti.input.text;
		}
		public function set text(value:String):void {
			frozenText.text = value;
			nti.input.text = value;
		}
	}
}