package views.video {
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.deg2rad;

	public class LoadingIcon extends Sprite {
		private var spot1:Image = new Image(Assets.getAtlas().getTexture("loading-piece"));
		private var spot2:Image = new Image(Assets.getAtlas().getTexture("loading-piece"));
		private var spot3:Image = new Image(Assets.getAtlas().getTexture("loading-piece"));
		private var spot4:Image = new Image(Assets.getAtlas().getTexture("loading-piece"));
		private var spot5:Image = new Image(Assets.getAtlas().getTexture("loading-piece"));
		private var spot6:Image = new Image(Assets.getAtlas().getTexture("loading-piece"));
		private var spot7:Image = new Image(Assets.getAtlas().getTexture("loading-piece"));
		private var spot8:Image = new Image(Assets.getAtlas().getTexture("loading-piece"));
		private var _isRunning:Boolean = false;
		private var spotVec:Vector.<Image> = new Vector.<Image>(8);
		public function LoadingIcon() {
			super();
			this.touchable = false;
			this.pivotX = 25;
			this.pivotY = 25;
			spot1.x = 20;
			spot1.y = 0;
			spot1.alpha = spot2.alpha = spot3.alpha = spot4.alpha = spot5.alpha = spot6.alpha = spot7.alpha = spot8.alpha = 0;
			spotVec[0] = spot1;
			addChild(spot1);

			spot2.x = 6;
			spot2.y = 6;
			spotVec[1] = spot2;
			addChild(spot2);

			spot3.x = 0;
			spot3.y = 20;
			spotVec[2] = spot3;
			addChild(spot3);
			
			spot4.x = 6;
			spot4.y = 34;
			spotVec[3] = spot4;
			addChild(spot4);
			
			spot5.x = 20;
			spot5.y = 40;
			spotVec[4] = spot5;
			addChild(spot5);

			spot6.x = 34;
			spot6.y = 34;
			spotVec[5] = spot6;
			addChild(spot6);
			
			spot7.x = 40;
			spot7.y = 20;
			spotVec[6] = spot7;
			addChild(spot7);
			
			spot8.x = 34;
			spot8.y = 6;
			spotVec[7] = spot8;
			addChild(spot8);
			
		}
		
		public function start():void {
			_isRunning = true;
			this.visible = true;
			var tween:Tween;
			this.rotation = 0;
			Starling.juggler.tween(this, 1.5, {
				transition: Transitions.LINEAR,
				rotation: deg2rad(360),
				repeatCount: 0
			});
			for (var i:int;i < 8;++i){
				spotVec[i].alpha = 0;
				tween = new Tween(spotVec[i], 0.5, Transitions.EASE_IN_BOUNCE);
				tween.animate("alpha",1);
				tween.delay = 0.1 + (i*0.0625);
				tween.repeatCount = 0;
				tween.reverse = true;
				Starling.juggler.add(tween);
			}
		}
		public function stop():void {
			_isRunning = false;
			this.visible = false;

			Starling.juggler.removeTweens(this);
			for (var i:int;i < 8;++i){
				Starling.juggler.removeTweens(spotVec[i]);
			}
		}

		public function get isRunning():Boolean {
			return _isRunning;
		}	
	}
}