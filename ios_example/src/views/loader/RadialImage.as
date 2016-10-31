package views.loader {
	import starling.textures.Texture;
	/**
	 * Картинка с радиальным заполнением
	 * @author rzer
	 */
	public class RadialImage extends RadialQuad {
		public function RadialImage(texture:Texture) {
			super(texture.width, texture.height);
			this.texture = texture;
		}
	}
	
}
