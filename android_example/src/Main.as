package {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	
	[SWF(width = "1280", height = "720", frameRate = "60", backgroundColor = "#121314")]
	public class Main extends Sprite {
		// Don't skip the "embedAsCFF"-part!
		[Embed(source="../fonts/Roboto-Medium.ttf", embedAsCFF="false", fontFamily="Roboto-Medium")]
		private static const Roboto:Class;
		
		public var mStarling:Starling;
		
		public function Main() {
			super();
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			Starling.multitouchEnabled = true;  // useful on mobile devices
			
			var viewPort:Rectangle = new Rectangle(0,0,stage.fullScreenWidth,stage.fullScreenHeight);
			
			mStarling = new Starling(StarlingRoot, stage, viewPort,null,"auto","auto");
			mStarling.stage.stageWidth = stage.fullScreenWidth;
			mStarling.stage.stageHeight = stage.fullScreenHeight;
			mStarling.simulateMultitouch = false;
			mStarling.showStatsAt("right","bottom");
			mStarling.enableErrorChecking = false;
			mStarling.antiAliasing = 16;
			mStarling.skipUnchangedFrames = false;
			
			mStarling.addEventListener(starling.events.Event.ROOT_CREATED, 
				function onRootCreated(event:Object, app:StarlingRoot):void {
					mStarling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
					app.start();
					mStarling.start();
					stage.addEventListener(ResizeEvent.RESIZE, onResize);
				});
		}
		private function onResize(event:flash.events.Event):void {
			trace(event);
		}
		
	}
}