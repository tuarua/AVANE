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
	
	public class SrollableContentv2 extends Sprite {
		private var _w:int = 1200;
		private var scrollBarVertical:Quad;
		private var scrollBarHorizontal:Quad;
		private var scrollBeganY:int;
		private var scrollBeganX:int;
		private var _h:int = 255;
		private var _fullHeight:uint;
		private var _fullWidth:uint;
		private var _spr:Sprite;
		private var _moveBy:int;
		public function SrollableContentv2(w:int,h:int,spr:Sprite=null,moveBy:int=50) {
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
			if(this.visible && mousePoint.x > 0 && mousePoint.x < _w && mousePoint.y > 0 && mousePoint.y < _h && !(_fullHeight < _h) && scrollBarVertical && _spr){
				var lastY:int;
				var cY:int = lastY = _spr.y;
				cY += (_moveBy* (event.delta));
				if(cY > 0) cY = 0;
				if(cY < (_h - _fullHeight))
					cY = (_h - _fullHeight);
				var sby:int;
				sby = (_h - scrollBarVertical.height) * (-cY/(_fullHeight-_h));
				if(sby < 0) sby = 0;
				if(sby > (_h - scrollBarVertical.height))
					sby = _h - scrollBarVertical.height;
				
				Starling.juggler.tween(scrollBarVertical, (Math.abs(lastY - cY) * 0.2)/_moveBy, {transition: Transitions.LINEAR,y: Math.round(sby)});
				Starling.juggler.tween(_spr, (Math.abs(lastY - cY) * 0.2)/_moveBy, {transition: Transitions.LINEAR,y: cY});
			}
		}
		public function set fullHeight(value:uint):void {
			_fullHeight = value;
		}
		public function set fullWidth(value:uint):void {
			_fullWidth = value;
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
			setupScrollBars();
			recalculate();
		}
		public function resize(w:int,h:int):void {
			_w = w;
			_h = h;
			this.mask = new Quad(w, h);
			setupScrollBars();
			recalculate();
		}
		private function setupScrollBars():void {
			if(scrollBarVertical && this.contains(scrollBarVertical))
				removeChild(scrollBarVertical);
			scrollBarVertical = new Quad(8,_h,0xCC8D1E);
			scrollBarVertical.alpha = 1;
			scrollBarVertical.visible = false;
			scrollBarVertical.x = _w - 12;
			
			scrollBarVertical.addEventListener(TouchEvent.TOUCH,onScrollBarVerticalTouch);
			addChild(scrollBarVertical);
			
			
			if(scrollBarHorizontal && this.contains(scrollBarHorizontal))
				removeChild(scrollBarHorizontal);			
			scrollBarHorizontal = new Quad(_w,8,0xCC8D1E);
			scrollBarHorizontal.alpha = 1;
			scrollBarHorizontal.visible = false;
			scrollBarHorizontal.y = _h - 10;
			scrollBarHorizontal.addEventListener(TouchEvent.TOUCH,onScrollBarHorizontalTouch);
			addChild(scrollBarHorizontal);
			
			
		}
		private function onScrollBarVerticalTouch(event:TouchEvent):void {
			var touch:Touch = event.getTouch(scrollBarVertical);
			if(touch && touch.phase == TouchPhase.BEGAN)
				scrollBeganY = globalToLocal(new Point(0,touch.globalY)).y-scrollBarVertical.y;
			if(touch && touch.phase == TouchPhase.ENDED)
				scrollBeganY = -1;
			if(touch && touch.phase == TouchPhase.MOVED){
				var sby:int = globalToLocal(new Point(touch.globalX,touch.globalY-(scrollBeganY))).y;
				if(sby < 0) sby = 0;
				if(sby > (_h - scrollBarVertical.height))
					sby = _h - scrollBarVertical.height;
				
				scrollBarVertical.y = sby;	
				var percentage:Number = sby / (_h-scrollBarVertical.height);
				_spr.y = Math.round(-((_fullHeight - _h)*percentage));
				
				
				
			}
		}
		private function onScrollBarHorizontalTouch(event:TouchEvent):void {
			var touch:Touch = event.getTouch(scrollBarHorizontal);
			if(touch && touch.phase == TouchPhase.BEGAN)
				scrollBeganX = globalToLocal(new Point(touch.globalX,0)).x-scrollBarHorizontal.x;
			if(touch && touch.phase == TouchPhase.ENDED)
				scrollBeganX = -1;
			
			
			if(touch && touch.phase == TouchPhase.MOVED){
				var sbx:int = globalToLocal(new Point(touch.globalX-(scrollBeganX),touch.globalY)).x;
				if(sbx < 0) sbx = 0;
				if(sbx > (_w - scrollBarHorizontal.width))
					sbx = _w - scrollBarHorizontal.width;
				scrollBarHorizontal.x = sbx;
				var percentage:Number = sbx / (_w-scrollBarHorizontal.width);
				_spr.x = Math.round(-((_fullWidth - _w)*percentage));
				
			}
			
			
		}
		public function recalculate():void {
			scrollBarVertical.scaleY = (_h == 0) ? 0 : _h/_fullHeight;
			scrollBarVertical.visible = !(_fullHeight <= _h);
			
			//scaleX so it's to nearest pixel
			scrollBarHorizontal.scaleX = (_w == 0) ? 0 : _w/_fullWidth;
			//trace(scrollBarHorizontal.scaleX);
			//trace(scrollBarHorizontal.width);
			//trace(scrollBarHorizontal.width / scrollBarHorizontal.scaleX);
			//trace( 1/ ((scrollBarHorizontal.width / scrollBarHorizontal.scaleX) / Math.round(scrollBarHorizontal.width))  );
			//to prevent the bar from being misaligned
			scrollBarHorizontal.scaleX = 1/ ((scrollBarHorizontal.width / scrollBarHorizontal.scaleX) / Math.round(scrollBarHorizontal.width));
			scrollBarHorizontal.visible = !(_fullWidth <= _w);
			
			//trace(_fullWidth);
			//trace(_w);
			
			
		}
		public function reset():void {
			if(_spr && scrollBarVertical)
				_spr.y = scrollBarVertical.y = 0;
			
			if(_spr && scrollBarHorizontal)
				_spr.x = scrollBarHorizontal.x = 0;
		}
		
	}
}