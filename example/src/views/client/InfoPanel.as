package views.client {
	import com.tuarua.ffprobe.Probe;
	import flash.geom.Rectangle;
	import events.InteractionEvent;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.Align;
	import starling.utils.deg2rad;
	
	import views.SrollableContent;

	public class InfoPanel extends Sprite {
		private var bg:Image;
		private var pane:Sprite = new Sprite();
		private var txtHolder:Sprite = new Sprite();
		private var h:int = 360;
		private var closeButton:Image = new Image(Assets.getAtlas().getTexture("close-icon"));
		private var infoList:SrollableContent;
		public function InfoPanel() {
			super();
			bg = new Image(Assets.getAtlas().getTexture("popmenu-bg"));
			bg.scale9Grid = new Rectangle(4,4,16,16);
			bg.blendMode = BlendMode.NONE;
			bg.touchable = false;
			bg.width = 880;
			bg.height = 400;
			
			addChild(bg);
			pane.x = 30;
			pane.addChild(txtHolder);
			
			infoList = new SrollableContent(800,h,pane);
			infoList.y = 20;
			
			addChild(infoList);
			closeButton.x = 870-24;
			closeButton.y = 10;
			closeButton.addEventListener(TouchEvent.TOUCH,onCloseTouch);
			addChild(closeButton);
			
		}
		private function onCloseTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(closeButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_CLOSE));
		}
		
		
		private function createTextField(text:String,indent:int = 0):TextField{
			var txt:TextField;
			txt = new TextField(600,32,text);
			txt.format.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,Align.LEFT,Align.TOP);
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
			
			infoList.fullHeight = (cnt*20)+12;
			infoList.init();
			
		}
	}
}