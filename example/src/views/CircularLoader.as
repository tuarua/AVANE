package views {
	import flash.geom.Rectangle;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import starling.filters.ColorMatrixFilter;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;

	public class CircularLoader extends Sprite {
		private var mskR:Quad;

		private var mskL:Quad;
		private var lbl:TextField;

		private var imgBG:Image;

		//private var imgCap:Image;
		//private var capContainer:Sprite = new Sprite();
		public function CircularLoader() {
			super();
			var imgR:Image = new Image(Assets.getAtlas().getTexture("semi-circle"));
			var imgL:Image = new Image(Assets.getAtlas().getTexture("semi-circle"));
			//imgCap = new Image(Assets.getAtlas().getTexture("semi-circle-cap"));
			
			imgBG = new Image(Assets.getAtlas().getTexture("semi-circle-bg2"));
			var w:int = imgR.width;
			//imgCap.y = -40;
			//capContainer.addChild(imgCap);
			//capContainer.y = 45;
			
			
			lbl = new TextField(90,32,"", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			lbl.hAlign = HAlign.CENTER;
			lbl.batchable = false;
			lbl.touchable = false;
			lbl.x = -w;
			lbl.y = 28;
			
			mskR = new Quad(w,w*2,0x000000);
			mskL = new Quad(w,w*2,0x000000);
			mskL.y = mskR.y = mskL.pivotY = mskR.pivotX = mskR.pivotY = mskR.pivotX = w;
			imgBG.touchable = false;
			imgBG.x = -w;
			imgBG.y = 0;
			imgL.scaleX = mskL.scaleX = -1;
			
			//var fltr:ColorMatrixFilter = new ColorMatrixFilter();
			//fltr.tint(0xFFFFFF);
			//imgR.filter = fltr;
			//imgL.filter = fltr;
			//imgL.alpha = imgR.alpha = 0.4;
			imgL.touchable = imgR.touchable = false;
			
			imgR.mask = mskR;
			imgL.mask = mskL;
			
			addChild(imgBG);
			addChild(imgR);
			addChild(imgL);
			//addChild(capContainer);
			addChild(lbl);
			
		}
		public function reset():void {
			imgBG.visible = true;
			mskL.rotation = mskR.rotation = 0;
			lbl.text = "";
		}
		public function update(value:Number):void {//percent eg 0.01
			lbl.text = (value*100).toPrecision(3)+"%";
			if(value >= 1){
				mskL.rotation = deg2rad(180);
				mskR.rotation = deg2rad(180);
				lbl.text = "100%";
				
				imgBG.visible = false;
			}else if(value < 0.5){
				mskR.rotation = deg2rad(360*value);
			}else{
				mskL.rotation = deg2rad(-(360*(value-0.5)));
				mskR.rotation = deg2rad(180);
			}
			//capContainer.rotation = deg2rad(360*value);
		}
		
	}
}