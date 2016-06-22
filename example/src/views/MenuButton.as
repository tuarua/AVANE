package views {
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	
	public class MenuButton extends Sprite {
		public function MenuButton() {
			super();
			var qb:QuadBatch = new QuadBatch();
			var one:Quad = new Quad(30,5,0xD8D8D8);
			var two:Quad = new Quad(30,5,0xD8D8D8);
			var three:Quad = new Quad(30,5,0xD8D8D8);
			
			two.y = 10;
			three.y = 20;
			
			qb.addQuad(one);
			qb.addQuad(two);
			qb.addQuad(three);
			this.addChild(qb);
		}
	}
}