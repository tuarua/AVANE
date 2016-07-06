package views {
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.Align;
	
	public class SimpleButton extends Sprite {
		private var bg:Quad;
		private var lbl:TextField;
		public function SimpleButton(text:String,w:int=80) {
			super();
			bg = new Quad(w,38,0x101010);
			
			lbl = new TextField(w,32,text);
			lbl.format.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,Align.CENTER);
			lbl.x = 0;
			lbl.y = 4;
			lbl.batchable = true;
			lbl.touchable = false;
			
			this.addChild(bg);
			this.addChild(lbl);
		}
	}
}