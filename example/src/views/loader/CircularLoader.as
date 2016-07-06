package views.loader {
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.Align;
	import starling.utils.deg2rad;

	public class CircularLoader extends Sprite {
		private var lbl:TextField;
		private var imgBG:Image;
		private var imgFill:RadialImage;
		public function CircularLoader() {
			super();
			imgBG = new Image(Assets.getAtlas().getTexture("semi-circle-bg2"));
			imgFill = new RadialImage(Assets.getAtlas().getTexture("semi-circle-full"));
			
			lbl = new TextField(90,32,"");
			lbl.format.setTo("Fira Sans Semi-Bold 13",13);
			lbl.format.horizontalAlign = Align.CENTER;
			lbl.format.color = 0xD8D8D8;
			
			lbl.batchable = false;
			lbl.touchable = false;
			lbl.y = 28;
			imgBG.touchable = false;
			imgBG.y = 0;
			imgBG.touchable = imgFill.touchable = false;
			addChild(imgBG);
			imgFill.scaleX = imgFill.scaleY = -1;
			imgFill.x = 90;
			imgFill.y = 90;
			addChild(imgFill);
			
			
			addChild(lbl);
		}
		public function reset():void {
			imgBG.visible = true;
			imgFill.angle = 0;
			lbl.text = "0%";
		}
		
		public function update(value:Number):void {//percent eg 0.01
			lbl.text = (value == 0.0 ) ? "0%" : (value*100).toPrecision(3)+"%";
			imgFill.angle = deg2rad(360*value);
		}
		
	}
}