package views {
	import starling.display.MeshBatch;
	import starling.display.Quad;
	import starling.display.Sprite;

	public class MenuButton extends Sprite {
		public function MenuButton() {
			super();
			var qb:MeshBatch = new MeshBatch();
			var bg:Quad = new Quad(30,25,0x121314);
			var one:Quad = new Quad(30,5,0xD8D8D8);
			var two:Quad = new Quad(30,5,0xD8D8D8);
			var three:Quad = new Quad(30,5,0xD8D8D8);
			
			two.y = 10;
			three.y = 20;
			
			qb.addMesh(bg);
			qb.addMesh(one);
			qb.addMesh(two);
			qb.addMesh(three);
			this.addChild(qb);
		}
	}
}