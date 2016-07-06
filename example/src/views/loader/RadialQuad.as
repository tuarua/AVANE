package views.loader {
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.Mesh;
	import starling.rendering.IndexData;
	import starling.rendering.VertexData;
	import starling.styles.MeshStyle;
	import starling.textures.Texture;
	
	/**
	 * Радиальная заливка
	 * @author rzer
	 */
	public class RadialQuad extends Mesh {
		
		public static const PI4:Number = Math.PI / 4;
		
		private var _angle:Number = 0;
		
		private var rect:Rectangle;
		private var center:Point;
		private var currentVertex:int = 0;
		private var startAngle:Number = 0;
		
		public function RadialQuad(width:Number, height:Number, color:uint = 0xffffff, startAngle:Number = Math.PI / 2) {
			
			this.startAngle = startAngle;
			
			rect = new Rectangle(0, 0, width, height);
			center = new Point(width / 2, height / 2);
			
			var vertexData:VertexData = new VertexData(MeshStyle.VERTEX_FORMAT, 4*4);
			var indexData:IndexData = new IndexData(6*4);
			
			super(vertexData, indexData);
			
			setupVertices();
			this.color = color;
		}
		
		//Процент заполнения круга
		public function get ratio():Number {
			return angle/Math.PI*0.5;
		}
		
		public function set ratio(value:Number):void {
			if (value > 1) value = 1;
			if (value < 0) value = 0;
			angle = value * 2 * Math.PI;
			
		}
		
		//Угол заполнения круга
		public function get angle():Number {
			return _angle;
		}
		
		public function set angle(value:Number):void {
			_angle = value;
			setupVertices();
		}
		
		private function setupVertices():void {
			
			indexData.numIndices = 0;
			vertexData.numVertices = 1 + Math.ceil(angle / PI4)*2;
			vertexData.trim();
			
			currentVertex = 0;
			
			vertexData.setPoint(0, "position", center.x,  center.y);
			
			if (texture){
				texture.setTexCoords(vertexData, 0, "texCoords", 0.5, 0.5);
			}else{
				vertexData.setPoint(0, "texCoords", 0.5, 0.5);
			}
			
			for (var a:Number = 0; a < angle; a += PI4){
				
				var b:Number = a + PI4;
				if (b > angle) b = angle;
				setupTriangle(pointOnBounds(a+startAngle), pointOnBounds(b+startAngle))
			}
			
			setRequiresRedraw();
			
		}
		
		private function setupTriangle(p1:Point, p2:Point):void {
			
			indexData.addTriangle(0, currentVertex + 1, currentVertex + 2);
			
			vertexData.setPoint(currentVertex + 1, "position", p2.x,  p2.y);
			vertexData.setPoint(currentVertex + 2, "position", p1.x,  p1.y);
			
			if (texture){
				texture.setTexCoords(vertexData, currentVertex + 1, "texCoords", p2.x / rect.width, p2.y / rect.height);
				texture.setTexCoords(vertexData, currentVertex + 2, "texCoords", p1.x / rect.width, p1.y / rect.height);
			}else{
				vertexData.setPoint(currentVertex + 1, "texCoords", p2.x / rect.width, p2.y / rect.height);
				vertexData.setPoint(currentVertex + 2, "texCoords", p1.x / rect.width, p1.y / rect.height);
			}
			
			currentVertex += 2;
		}
		
		//Возвращает точку пересечения луча выходящего из центра с границами объекта
		public function pointOnBounds(angle:Number):Point{
			var point:Point = normalizedPoint(angle);
			
			point.offset(1, 1);
			point.x *= 0.5 * rect.width;
			point.y *= 0.5 * rect.height;
			
			return point;
		}
		
		//Возвращает значение от -1 до 1;
		public function normalizedPoint(a:Number):Point{
			
			a = a % (Math.PI * 2);
			if (a < 0) a += 2 * Math.PI;
			
			var s:Number = Math.floor(a / PI4) % 8;
			var p:Number = (s % 2 == 0) ? Math.tan(a % PI4) : Math.tan(PI4 - a % PI4);
			
			if (s == 0) return new Point(1, p);
			else if (s == 1) return new Point(p, 1);
			else if (s == 2) return new Point(-p, 1);
			else if (s == 3) return new Point(-1, p);
			else if (s == 4) return new Point(-1, -p);
			else if (s == 5) return new Point(-p, -1);
			else if (s == 6) return new Point(p, -1);
			return new Point(1, -p);
		}
		
	}
	
}
