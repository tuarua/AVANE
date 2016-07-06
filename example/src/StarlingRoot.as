package {
	import com.tuarua.AVANE;
	import com.tuarua.ffmpeg.Logger;
	import com.tuarua.ffmpeg.constants.LogLevel;
	import com.tuarua.ffmpeg.gets.AvailableFormat;
	import com.tuarua.ffmpeg.gets.Device;
	import com.tuarua.ffmpeg.gets.Filter;
	import com.tuarua.ffmpeg.gets.HardwareAcceleration;
	
	import events.InteractionEvent;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	import views.BasicExample;
	import views.DesktopCapture;
	import views.ExampleSelector;
	import views.MenuButton;
	import views.loader.RadialImage;
	import views.UniversalPlayer;
	import views.client.AdvancedClient;

	public class StarlingRoot extends Sprite {
		private var avANE:AVANE = new AVANE();
		private var advancedClient:AdvancedClient;
		private var universalPlayer:UniversalPlayer;
		private var basicExample:BasicExample;
		private var desktopCapture:DesktopCapture;
		private var holder:Sprite = new Sprite();
		private var menuButton:MenuButton = new MenuButton();
		private var upTexture:Texture = Assets.getAtlas().getTexture("arrow-up");
		private var backButton:Image = new Image(upTexture);
		private var selectedExample:int = 0;
		private var exampleSelector:ExampleSelector;
		
		private var ri:RadialImage = new RadialImage(Assets.getAtlas().getTexture("semi-circle-bg2"));
		
		public function StarlingRoot() {
			super();
			TextField.registerBitmapFont(Fonts.getFont("fira-sans-semi-bold-13"));
		}
		
		public function start():void {
			exampleSelector = new ExampleSelector();
			exampleSelector.x = -180;
			exampleSelector.y = 10;
			
			exampleSelector.universalButton.addEventListener(TouchEvent.TOUCH,onUniversalTouch);
			exampleSelector.basicButton.addEventListener(TouchEvent.TOUCH,onBasicTouch);
			exampleSelector.advancedButton.addEventListener(TouchEvent.TOUCH,onAdvancedTouch);
			exampleSelector.captureButton.addEventListener(TouchEvent.TOUCH,onCaptureTouch);
			
			Logger.init(1280,500);
			
			
			universalPlayer = new UniversalPlayer(avANE);
			
			advancedClient = new AdvancedClient(avANE);
			advancedClient.y = 40;
			advancedClient.suspend();
			holder.addChild(advancedClient);
			
			basicExample = new BasicExample(avANE);
			basicExample.suspend();
			holder.addChild(basicExample);
			
			desktopCapture = new DesktopCapture(avANE);
			desktopCapture.suspend();
			desktopCapture.y = 40;
			holder.addChild(desktopCapture);
			
			
			//trace("AVANE configuration:",avANE.getBuildConfiguration());
			//trace("AVANE library versions:",avANE.getVersion());
			//trace("AVANE FFmpeg License:",avANE.getLicense());
			
			menuButton.x = 10;
			menuButton.y = 10;
			menuButton.addEventListener(TouchEvent.TOUCH,onMenuTouch);
			addChild(menuButton);
			
			backButton.pivotX = backButton.pivotY = 15;
			backButton.rotation = Math.PI*1.5;
			backButton.x = 25;
			backButton.y = 22;
			
			backButton.addEventListener(TouchEvent.TOUCH,onBackTouch);
			
			backButton.visible = false;
			addChild(backButton);
			
			
			holder.addChild(universalPlayer);
			addChild(holder);
			
			
			addChild(exampleSelector);
			
			
		}
		private function onBasicTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(exampleSelector.basicButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED && selectedExample != 1){
				closeMenu();
				clearAll();
				selectedExample = 1;
				Starling.current.skipUnchangedFrames = true;
				basicExample.resume();
			}
		}
		private function onAdvancedTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(exampleSelector.advancedButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED && selectedExample != 2){
				closeMenu();
				clearAll();
				selectedExample = 2;
				advancedClient.resume();
			}
		}
		
		private function onCaptureTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(exampleSelector.captureButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED && selectedExample != 3){
				closeMenu();
				clearAll();
				selectedExample = 3;
				Starling.current.skipUnchangedFrames = true;
				desktopCapture.resume();
			}
		}
		
		private function onUniversalTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(exampleSelector.universalButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED && selectedExample != 0){
				closeMenu();
				clearAll();
				selectedExample = 0;
				Starling.current.skipUnchangedFrames = false;
				universalPlayer.resume();
			}
		}
		private function onMenuTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(menuButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED){
				
				menuButton.visible = false;
				menuButton.x = 210;
				backButton.visible = true;
				if(selectedExample == 2){
					advancedClient.freeze();
				}	
				Starling.juggler.tween(exampleSelector, 0.35, {transition: Transitions.EASE_OUT,x: 20});
				Starling.juggler.tween(holder, 0.35, {transition: Transitions.EASE_OUT,x: 200});
				Starling.juggler.tween(backButton, 0.35, {transition: Transitions.EASE_OUT,x: 225});
			}	
		}
		
		private function clearAll():void {
			universalPlayer.suspend();
			advancedClient.suspend();
			basicExample.suspend();
			desktopCapture.suspend();
		}
		
		private function onBackTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(backButton, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)
				closeMenu();	
		}
		
		private function closeMenu():void {
			menuButton.visible = true;
			backButton.visible = false;
			backButton.x = 25;
			Starling.juggler.tween(exampleSelector, 0.35, {transition: Transitions.EASE_OUT,x: -180,
				onComplete: function():void {
				if(selectedExample == 2){
					advancedClient.unfreeze();
				}
			}});
			Starling.juggler.tween(holder, 0.35, {transition: Transitions.EASE_OUT,x: 0});
			Starling.juggler.tween(menuButton, 0.35, {transition: Transitions.EASE_OUT,x: 10});
		}
		
	}
}