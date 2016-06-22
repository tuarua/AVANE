package views.client {
	import com.tuarua.ffprobe.Probe;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import events.InteractionEvent;
	
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;

	public class InfoPanel extends Sprite {
		private var bgTexture:Scale9Textures;
		private var bg:Scale9Image;
		private var pane:Sprite = new Sprite();
		private var txtHolder:Sprite = new Sprite();
		private var scrollBar:Quad;
		private var nScrollbarOffset:int = 20;
		private var scrollBeganY:int;
		private var h:int = 360;
		private var closeButton:Image = new Image(Assets.getAtlas().getTexture("close-icon"));
		public function InfoPanel() {
			super();
			bgTexture = new Scale9Textures(Assets.getAtlas().getTexture("popmenu-bg"),new Rectangle(4,4,16,16));
			bg = new Scale9Image(bgTexture);
			bg.blendMode = BlendMode.NONE;
			bg.touchable = false;
			bg.width = 880;
			bg.height = 400;
			
			pane.y = nScrollbarOffset;
			pane.clipRect = new Rectangle(0,0,800,h);
			
			addChild(bg);
			pane.x = 30;
			pane.addChild(txtHolder);
			addChild(pane);
			closeButton.x = 870-24;
			closeButton.y = 10;
			closeButton.addEventListener(TouchEvent.TOUCH,onCloseTouch);
			addChild(closeButton);
			
			setupScrollBar();
		}
		private function onCloseTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(closeButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_CLOSE));
		}
		private function setupScrollBar():void {
			if(scrollBar && this.contains(scrollBar)) removeChild(scrollBar);
			scrollBar = new Quad(8,h,0xCC8D1E);
			scrollBar.alpha = 1;
			scrollBar.visible = false;
			scrollBar.y = nScrollbarOffset;
			scrollBar.x = 850 - 24;
			scrollBar.addEventListener(TouchEvent.TOUCH,onScrollBarTouch);
			addChild(scrollBar);
		}
		private function onScrollBarTouch(event:TouchEvent):void {
			var touch:Touch = event.getTouch(scrollBar);
			if(touch && touch.phase == TouchPhase.BEGAN) scrollBeganY = globalToLocal(new Point(0,touch.globalY)).y-scrollBar.y;
			if(touch && touch.phase == TouchPhase.ENDED) scrollBeganY = -1;
			//if(touch && touch.phase == TouchPhase.HOVER) Starling.juggler.tween(scrollBar, 0.2, {transition: Transitions.LINEAR,alpha: 1});
			//if(touch == null) Starling.juggler.tween(scrollBar, 0.2, {transition: Transitions.LINEAR,alpha: 0});
			
			if(touch && touch.phase == TouchPhase.MOVED){
				var y:int = globalToLocal(new Point(touch.globalX,touch.globalY-(scrollBeganY))).y;
				if(y < pane.y) y = pane.y;
				if(y > (pane.y + pane.height - scrollBar.height)) y = pane.y + pane.height - scrollBar.height;
				scrollBar.y = y;	
				var percentage:Number = (y - nScrollbarOffset) / (h-scrollBar.height);
				txtHolder.y = -Math.round(((txtHolder.height - h)*percentage));
			}
		}
		private function createTextField(text:String,indent:int = 0):TextField{
			var txt:TextField;
			txt = new TextField(600,32,text, "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			txt.hAlign = HAlign.LEFT;
			txt.vAlign = VAlign.TOP;
			txt.batchable = true;
			txt.touchable = false;
			txt.x = (indent * 40)+20;
			return txt;
		}
		
		public function update(probe:Probe):void {
			//clear all
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			
			var s:String = JSON.stringify(probe);
			var obj:Object = JSON.parse(s);
			
			var lbl:TextField;
			var value:TextField;
			var valueStr:String;
			var cnt:int = 0;
			var icn:Image = new Image(Assets.getAtlas().getTexture("close-icon"));
			for (var prop:* in obj) {
				lbl = createTextField(prop);
				lbl.y = cnt * 20;
				
				txtHolder.addChild(lbl);
				
				
				if(typeof(obj[prop]) == "object"){
					icn = new Image(Assets.getAtlas().getTexture("tree-icon"));
					icn.pivotX = 3;
					icn.pivotY = 6;
					icn.rotation = deg2rad(90);
					icn.x = lbl.x-10;
					icn.y = (cnt * 20)+8;
					txtHolder.addChild(icn);
				}else{
					value = createTextField((typeof(obj[prop]) == "string") ? '"'+obj[prop]+'"' : obj[prop]);
					value.x = 300;
					value.y =  cnt * 20;
					txtHolder.addChild(value);
				}
				cnt++;
				for (var prop2:* in obj[prop]){
					lbl = createTextField(prop2,1);
					lbl.y = cnt * 20;
					txtHolder.addChild(lbl);
					if(typeof(obj[prop][prop2]) == "object"){
						icn = new Image(Assets.getAtlas().getTexture("tree-icon"));
						icn.pivotX = 3;
						icn.pivotY = 6;
						icn.rotation = deg2rad(90);
						icn.x = lbl.x-10;
						icn.y = (cnt * 20)+8;
						txtHolder.addChild(icn);
					}else{
						value = createTextField((typeof(obj[prop][prop2]) == "string") ? '"'+obj[prop][prop2]+'"' : obj[prop][prop2]);
						value.x = 300;
						value.y = cnt * 20;
						txtHolder.addChild(value);
					}
					cnt++;
					
					if(typeof(obj[prop][prop2]) == "object"){
						for (var prop3:* in obj[prop][prop2]){
							lbl = createTextField(prop3,2);
							
							if(typeof(obj[prop][prop2][prop3]) != "object"){
								value = createTextField((typeof(obj[prop][prop2][prop3]) == "string") ? '"'+obj[prop][prop2][prop3]+'"' : obj[prop][prop2][prop3]);
								value.x = 300;
								value.y = cnt * 20;
								txtHolder.addChild(value);
							}
							
							lbl.y = cnt * 20;
							txtHolder.addChild(lbl);
							cnt++;
						
							if(typeof(obj[prop][prop2][prop3]) == "object"){
								for (var prop4:* in obj[prop][prop2][prop3]){
									lbl = createTextField(prop4,3);
									if(typeof(obj[prop][prop2][prop3][prop4]) != "object"){
										value = createTextField((typeof(obj[prop][prop2][prop3][prop4]) == "string") ? '"'+obj[prop][prop2][prop3][prop4]+'"' : obj[prop][prop2][prop3][prop4]);
										value.x = 300;
										value.y = cnt * 20;
										txtHolder.addChild(value);
									}
									
									
									lbl.y = cnt * 20;
									txtHolder.addChild(lbl);
									cnt++;
									
									/*
									trace(typeof(obj[prop][prop2][prop3][prop4]));
									if(typeof(obj[prop][prop2][prop3][prop4]) == "object"){
										for (var prop5:* in obj[prop][prop2][prop3][prop4]){
											trace("level 5");
										}
									}
									*/
								}
							}
							
							
							
						}
						
					}
				}
				
				
			
				
			}
			
			scrollBar.y = nScrollbarOffset;
			scrollBar.scaleY = h/txtHolder.height;
			scrollBar.visible = !(pane.height < h);

			trace(scrollBar.visible);
			
			
		}
	}
}