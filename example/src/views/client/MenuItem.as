package views.client {
	import events.InteractionEvent;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	public class MenuItem extends Sprite {
		private var bg:Quad;
		private var bgOff:Quad;
		private var w:int = 120;
		private var isSelected:Boolean;
		
		private var lbl:TextField;
		private var type:int;
		public function MenuItem(_lbl:String,_type:int,_isSelected:Boolean=false) {
			super();
			type = _type;
			isSelected = _isSelected;
			bg = new Quad(w,27,0x0D1012);
			bgOff = new Quad(w,28,0x666666);
			bg.alpha = 0.92;
			bgOff.alpha = 0.25;
			bgOff.visible = !isSelected;
			
			lbl = new TextField(w,32,_lbl, "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			lbl.hAlign = HAlign.CENTER;
			lbl.x = 0;
			lbl.batchable = true;
			lbl.touchable = false;
			bgOff.useHandCursor = false;
			bgOff.addEventListener(TouchEvent.TOUCH,onClick);
			addChild(bg);
			addChild(bgOff);
			addChild(lbl);
		}
		
		protected function onClick(event:TouchEvent):void {
			var touch:Touch = event.getTouch(bgOff);
			if(touch && touch.phase == TouchPhase.ENDED)
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_MENU_ITEM_MENU,{type:type}));
		}
		public function setSelected(_b:Boolean):void {
			isSelected = _b;
			bgOff.visible = !isSelected;
		}
	}
}
