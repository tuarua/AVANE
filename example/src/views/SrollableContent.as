package views {
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class SrollableContent extends Sprite {
		private var _w:int = 1200;
		private var scrollBar:Quad;
		private var scrollBeganY:int;
		private var _h:int = 255;
		private var _fullHeight:uint;
		private var _spr:Sprite;
		private var _moveBy:int;
		public function SrollableContent(w:int,h:int,spr:Sprite=null,moveBy:int=50) {
			super();
			_w = w;
			_h = h;
			_spr = spr;
			_moveBy = moveBy;
			this.mask = new Quad(w, h);
			if(spr)
				addChild(spr);
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
		}
		protected function onMouseWheel(event:MouseEvent):void {
			var mousePoint:Point = this.globalToLocal(new Point(Starling.current.nativeStage.mouseX,Starling.current.nativeStage.mouseY));
			if(this.visible && mousePoint.x > 0 && mousePoint.x < _w && mousePoint.y > 0 && mousePoint.y < _h && !(_fullHeight < _h) && scrollBar && _spr){
				var lastY:int;
				var cY:int = lastY = _spr.y;
				cY += (_moveBy* (event.delta));
				if(cY > 0) cY = 0;
				if(cY < (_h - _fullHeight))
					cY = (_h - _fullHeight);
				var sby:int;
				sby = (_h - scrollBar.height) * (-cY/(_fullHeight-_h));
				if(sby < 0) sby = 0;
				if(sby > (_h - scrollBar.height))
					sby = _h - scrollBar.height;
				
				Starling.juggler.tween(scrollBar, (Math.abs(lastY - cY) * 0.2)/_moveBy, {transition: Transitions.LINEAR,y: Math.round(sby)});
				Starling.juggler.tween(_spr, (Math.abs(lastY - cY) * 0.2)/_moveBy, {transition: Transitions.LINEAR,y: cY});
			}
		}
		public function set fullHeight(value:uint):void {
			_fullHeight = value;
		}
		public function init(w:int=-1,h:int=-1,spr:Sprite=null):void {
			if(w > -1) _w = w;
			if(h > -1) _h = h;
			//remove all existing children
			var k:int = this.numChildren;
			while(k--)
				this.removeChildAt(k);
			if(spr)
				_spr = spr;
			if(_spr)
				addChild(_spr);
			setupScrollBar();
			recalculate();
		}
		public function resize(w:int,h:int):void {
			_w = w;
			_h = h;
			this.mask = new Quad(w, h);
			setupScrollBar();
			recalculate();
		}
		private function setupScrollBar():void {
			if(scrollBar && this.contains(scrollBar))
				removeChild(scrollBar);
			scrollBar = new Quad(8,_h,0xCC8D1E);
			scrollBar.alpha = 1;
			scrollBar.visible = false;
			scrollBar.x = _w - 12;
			scrollBar.addEventListener(TouchEvent.TOUCH,onScrollBarTouch);
			addChild(scrollBar);
		}
		private function onScrollBarTouch(event:TouchEvent):void {
			var touch:Touch = event.getTouch(scrollBar);
			if(touch && touch.phase == TouchPhase.BEGAN)
				scrollBeganY = globalToLocal(new Point(0,touch.globalY)).y-scrollBar.y;
			if(touch && touch.phase == TouchPhase.ENDED)
				scrollBeganY = -1;
			if(touch && touch.phase == TouchPhase.MOVED){
				var sby:int = globalToLocal(new Point(touch.globalX,touch.globalY-(scrollBeganY))).y;
				if(sby < 0) sby = 0;
				if(sby > (_h - scrollBar.height))
					sby = _h - scrollBar.height;
				
				scrollBar.y = sby;	
				var percentage:Number = sby / (_h-scrollBar.height);
				_spr.y = Math.round(-((_fullHeight - _h)*percentage));
			}
		}
		public function recalculate():void {
			scrollBar.scaleY = (_h == 0) ? 0 : _h/_fullHeight;
			scrollBar.visible = !(_fullHeight < _h);
		}
		public function reset():void {
			if(_spr && scrollBar)
				_spr.y = scrollBar.y = 0;
		}
		
	}
}