package views.forms {
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import events.FormEvent;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Align;
	
	public class DropDown extends Sprite { //5 draw calls - not nice
		private var _id:String;
		private var w:int;
		private var h:int;
		private var _selected:int = 0;
		private var items:Vector.<Object>;
		private var bg:Image;
		private var listBg:Image;
		private var listBgTexture:Texture;
		private var listContainer:Sprite = new Sprite();
		private var hover:Quad;
		private var txt:TextField;
		private var listOuterContainer:Sprite = new Sprite();
		private var tween:Tween;
		private var isEnabled:Boolean = true;

		private var textFormat:TextFormat;
		public function DropDown(_w:int,_items:Vector.<Object>) {
			super();
			w = _w;
			items = _items;
			textFormat = new TextFormat();
			textFormat.setTo("Fira Sans Semi-Bold 13",13);
			textFormat.horizontalAlign = Align.LEFT;
			textFormat.verticalAlign = Align.CENTER;
			textFormat.color = 0xD8D8D8;
			render();
		}
		private function render():void {
			h = (items.length*20) + 5;
			bg = new Image(Assets.getAtlas().getTexture("dropdown-bg"));
			bg.scale9Grid = new Rectangle(4, 0, 23, 25);
			bg.width = w;
			bg.blendMode = BlendMode.NONE;
			
			hover = new Quad(w-6,20,0xCC8D1E);
			hover.alpha = 0.4;
			
			txt = new TextField(w,26,items[_selected].label);
			txt.format = textFormat;
			
			txt.x = 8;
			txt.batchable = true;
			txt.touchable = false;
			
			bg.addEventListener(TouchEvent.TOUCH,onTouch);
			
			listBg = new Image(Assets.getAtlas().getTexture("dropdown-items-bg"));
			listBg.scale9Grid = new Rectangle(4, 4, 41, 17);
			
			listBg.blendMode = BlendMode.NONE;
			listBg.width = w;
			listBg.height = h;
			
			listContainer.y = 25-h;
			listOuterContainer.mask = new Quad(w, h);
			listOuterContainer.mask.y = 25
			
			var k:int = listContainer.numChildren;
			while(k--){
				listContainer.getChildAt(k).dispose();
				listContainer.removeChildAt(k);
			}
			
			listContainer.addChild(listBg);
			hover.x = 3;
			hover.y = (_selected*20)+2;
			listContainer.addChild(hover);
			
			var itmLbl:TextField;
			for (var i:int=0, l:int=items.length; i<l; ++i){
				itmLbl = new TextField(w,26,items[i].label);
				itmLbl.format = textFormat;
				itmLbl.x = 8;
				itmLbl.y = (i*20) + 0;
				listContainer.addChild(itmLbl);
			}
			
			listContainer.addEventListener(TouchEvent.TOUCH,onListTouch);
			listOuterContainer.addChild(listContainer);
			listOuterContainer.visible = false;
			addChild(listOuterContainer);
			addChild(bg);
			addChild(txt);
		}
		
		protected function onTouch(event:TouchEvent):void{
			event.stopPropagation();
			var touch:Touch = event.getTouch(bg, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED && isEnabled)
				open();
		}
		
		private function open():void {
			Starling.juggler.removeTweens(listContainer);
			tween = new Tween(listContainer, 0.15, Transitions.EASE_OUT);
			tween.animate("y",25);
			listOuterContainer.visible = true;
			Starling.juggler.add(tween);
			Starling.current.nativeStage.addEventListener(MouseEvent.CLICK,onClick);
			Starling.current.nativeStage.addEventListener(MouseEvent.RIGHT_CLICK,onClick);
			this.dispatchEvent(new FormEvent(FormEvent.FOCUS_IN,null));
		}
		private function onClick(event:MouseEvent):void {
			Starling.current.nativeStage.removeEventListener(MouseEvent.CLICK,onClick);
			close();
		}
		private function close():void {
			Starling.juggler.removeTweens(listContainer);
			tween = new Tween(listContainer, 0.15, Transitions.EASE_IN);
			tween.animate("y",25-h);
			Starling.juggler.add(tween);
			tween.onComplete = function():void {
				listOuterContainer.visible = false;
				hover.y = (_selected*20)+2;
			}
			this.dispatchEvent(new FormEvent(FormEvent.FOCUS_OUT,null));
		}
		public function enable(_b:Boolean):void {
			isEnabled = _b;
			this.alpha = (_b) ? 1 : 0.25;
		}
		protected function onListTouch(event:TouchEvent):void {
			var hoverTouch:Touch = event.getTouch(listContainer, TouchPhase.HOVER);
			var clickTouch:Touch = event.getTouch(listContainer, TouchPhase.ENDED);
			if(hoverTouch && isEnabled){
				var p:Point = hoverTouch.getLocation(listContainer,p);
				var proposedHover:int = Math.floor((p.y)/20);
				if(proposedHover > -1 && proposedHover < items.length && tween.isComplete)
					hover.y = (proposedHover*20)+2;
			}else if(clickTouch && isEnabled){
				var pClick:Point = clickTouch.getLocation(listContainer,pClick);
				var proposedSelected:int = Math.floor((pClick.y)/20);
				if(proposedSelected > -1 && proposedSelected < items.length){
					_selected = proposedSelected;
					txt.text = items[_selected].label;
					this.dispatchEvent(new FormEvent(FormEvent.CHANGE,{value:items[_selected].value},false));
				}
			}
		}

		public function get selected():int {
			return _selected;
		}
		public function set selected(value:int):void {
			if(value > -1){
				_selected = value;
				txt.text = items[_selected].label;
				hover.y = (_selected*20)+2;
			}
			
		}
		
		public function update(_items:Vector.<Object>):void {
			items = _items;
			var k:int = this.numChildren;
			while(k--){
				this.getChildAt(k).dispose();
				this.removeChildAt(k);
			}
			render();
		}

		public function get id():String {
			return _id;
		}

		public function set id(value:String):void {
			_id = value;
		}

	}
}