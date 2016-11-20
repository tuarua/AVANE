package views.video.controls {
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	import events.InteractionEvent;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MeshBatch;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Align;
	
	import utils.TimeUtils;
	
	public class ControlsContainer extends Sprite {
		private var bg:MeshBatch = new MeshBatch();
		private var w:int = 1280;
		private var timeTxt:TextField;
		private var durationTxt:TextField;
		private var qualityTxt:TextField;
		private var duration:Number = 0;
		private var nCurrentTime:Number = 0;
		
		private var dividerImage:Image = new Image(Assets.getAtlas().getTexture("controls-divider"));
		
		private var playTexture:Texture = Assets.getAtlas().getTexture("controls-play");
		private var playHoverTexture:Texture = Assets.getAtlas().getTexture("controls-play-over");
		private var playBtn:Button = new Button(playTexture,"",playTexture,playHoverTexture,playTexture);
		
		private var pauseHoverTexture:Texture = Assets.getAtlas().getTexture("controls-pause-over");
		private var pauseTexture:Texture = Assets.getAtlas().getTexture("controls-pause");
		private var pauseBtn:Button = new Button(pauseTexture,"",pauseTexture,pauseHoverTexture,pauseTexture);
		
	
		private var progressEndTexture:Texture = Assets.getAtlas().getTexture("controls-scrub-edge");
		private var progressEndLeftImage:Image = new Image(progressEndTexture);
		private var progressEndRightImage:Image = new Image(progressEndTexture);
		
		private var progressCurrentEndImage:Image = new Image(Assets.getAtlas().getTexture("controls-progress-edge"));
		
		private var volumeEdgeLeftImage:Image = new Image(progressEndTexture);
		private var volumeEdgeRightImage:Image = new Image(progressEndTexture);
		
		private var scrubTexture:Texture = Assets.getAtlas().getTexture("controls-scrub-handle");
		private var scrubTextureHover:Texture = Assets.getAtlas().getTexture("controls-scrub-handle-hover");
		private var scrubImage:Image = new Image(scrubTexture);
		
		private var volumeScrubImage:Image = new Image(scrubTexture);
		private var volumeTexture:Texture = Assets.getAtlas().getTexture("controls-volume");
		private var volumeMutedTexture:Texture = Assets.getAtlas().getTexture("controls-volume-muted");
		private var volumeBtn:Image = new Image(volumeTexture);
		
		private var volumeHit:Quad = new Quad(90,20,0x131313);
		private var volumeScrubHit:Quad = new Quad(50,6,0xCCFF00);
		private var volumeBG:Quad = new Quad(50,6,0x3C3C3C);
		private var volumeCurrent:Quad = new Quad(50,6,0xCC8D1E);
		private var volumeHolder:Sprite = new Sprite();
		
		private var scrubHit:Quad = new Quad(640,20,0x131313);
		private var progressBG:Quad = new Quad(640,6,0x090909);
		private var progressAvailable:Quad = new Quad(640,6,0x3C3C3C);
		private var progressCurrent:Quad = new Quad(640,6,0xCC8D1E);
		
		private var isHiding:Boolean = false;
		private var isShowing:Boolean = false;
		private var hideTween:Tween;
		private var holder:Sprite = new Sprite();
		private var progressHolder:Sprite = new Sprite();
		private var scrubBeganX:int;
		private var _isScrubbing:Boolean = false;
		private var _isScrubbable:Boolean = true;
		private var _isLive:Boolean = false;

		private var proposedTime:Number;
		private var _isMuted:Boolean = false;
		private var _volume:Number;
		private var _isVolumeScrubbing:Boolean = false;
		private var volumeScrubBeganX:int;
		private var progressScaleFactor:int = 1;
		private var availableProgress:Number = 0;
		public function ControlsContainer() {
			super();
			
			_volume = 0.5;
			
			timeTxt = new TextField(180,32,"");
			timeTxt.format.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,Align.LEFT,Align.TOP)
			timeTxt.touchable = false;
			//timeTxt.autoSize = TextFieldAutoSize.VERTICAL;
			
			timeTxt.x = 88;
			progressCurrent.scaleX = progressAvailable.scaleX = 0;
			progressAvailable.visible = progressCurrent.visible = false;
			
			progressCurrent.x = progressAvailable.x = progressBG.x = 150;
			progressCurrentEndImage.y = volumeCurrent.y = volumeEdgeRightImage.y = volumeEdgeLeftImage.y = volumeBG.y = progressEndRightImage.y = progressEndLeftImage.y = progressCurrent.y = progressAvailable.y = progressBG.y = 22;
			volumeScrubImage.pivotY = volumeScrubImage.pivotX = scrubImage.pivotY = scrubImage.pivotX = 6;
			
			progressCurrentEndImage.visible = false;
			
			volumeScrubImage.y = scrubImage.y = 25;
			scrubImage.x = progressBG.x;
			scrubImage.visible = false;
			scrubImage.addEventListener(TouchEvent.TOUCH,onScrubTouch);
			volumeScrubHit.x = progressCurrentEndImage.x = scrubHit.x = progressEndLeftImage.x = progressBG.x;
			
			volumeScrubHit.y = volumeHit.y = scrubHit.y = 18;
			volumeEdgeRightImage.scaleX = progressEndRightImage.scaleX = -1;
			progressEndRightImage.x = progressBG.x + progressBG.width;
			
			
			
			
			volumeCurrent.touchable = volumeEdgeRightImage.touchable = volumeEdgeLeftImage.touchable = progressEndLeftImage.touchable = progressEndRightImage.touchable = progressCurrent.touchable = progressBG.touchable = false;	
			progressHolder.addEventListener(TouchEvent.TOUCH,onProgressHover);
			
			volumeCurrent.x = volumeBG.x = 32;
			//volumeScrubHit.x = 28;
			volumeEdgeLeftImage.x = volumeBG.x;
			volumeScrubImage.visible = false;
			volumeScrubImage.addEventListener(TouchEvent.TOUCH,onVolumeScrubTouch);
			volumeScrubImage.x = volumeBG.x + (volumeBG.width*_volume);
			volumeCurrent.scaleX  = _volume;
			volumeHolder.addEventListener(TouchEvent.TOUCH,onVolumeHover);
			volumeBG.addEventListener(TouchEvent.TOUCH,onVolumeScrubHover);
			
			volumeEdgeRightImage.x = volumeEdgeLeftImage.x + volumeBG.width;
			durationTxt = new TextField(180,32,"");
			durationTxt.format.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,Align.LEFT,Align.TOP);
			durationTxt.touchable = false;
			durationTxt.batchable = true;
			
			qualityTxt = new TextField(60,32,"");
			qualityTxt.format.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,Align.CENTER,Align.TOP);
			qualityTxt.touchable = false;
			qualityTxt.batchable = true;
			qualityTxt.y = durationTxt.y = timeTxt.y = 16;
			
			durationTxt.x = w-475;
			qualityTxt.x = w-398;
			

			pauseBtn.x = playBtn.x = 25;
			volumeBtn.useHandCursor = pauseBtn.useHandCursor = playBtn.useHandCursor = false;
			pauseBtn.y = playBtn.y = 7;
			
			volumeHolder.x = w-312;
			volumeBtn.y = 16;
			volumeBtn.addEventListener(TouchEvent.TOUCH,onVolumeToggle);
			
			
			
			playBtn.visible = false;
			playBtn.addEventListener(TouchEvent.TOUCH,onPlayPauseToggle);
			pauseBtn.addEventListener(TouchEvent.TOUCH,onPlayPauseToggle);
			
			this.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			

			addBG();
			holder.addChild(playBtn);
			holder.addChild(pauseBtn);
			holder.addChild(timeTxt);
			holder.addChild(qualityTxt);
			holder.addChild(durationTxt);
			
			progressHolder.addChild(scrubHit);
			progressHolder.addChild(progressBG);
			progressHolder.addChild(progressAvailable);
			//progressHolder.addChild(progressCurrentEndImage);
			progressHolder.addChild(progressCurrent);
			progressHolder.addChild(progressEndLeftImage);
			progressHolder.addChild(progressEndRightImage);
			
			progressHolder.addChild(scrubImage);
			holder.addChild(progressHolder);
			
			volumeHolder.addChild(volumeHit);
			volumeHolder.addChild(volumeBtn);
			//volumeHolder.addChild(volumeScrubHit);
			volumeHolder.addChild(volumeBG);
			volumeHolder.addChild(volumeCurrent);
			volumeHolder.addChild(volumeEdgeLeftImage);
			volumeHolder.addChild(volumeEdgeRightImage);
			
			volumeHolder.addChild(volumeScrubImage);

			holder.addChild(volumeHolder);
			addChild(holder);
		}
		
	
		protected function onVolumeScrubTouch(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(volumeScrubImage);
			if(touch != null && touch.phase == TouchPhase.BEGAN){
				volumeScrubImage.texture = scrubTextureHover;
				_isVolumeScrubbing = true;
				volumeScrubBeganX = globalToLocal(new Point(0,touch.globalX)).x-volumeScrubImage.x;
			}else if(touch != null && touch.phase == TouchPhase.ENDED){
				volumeScrubImage.texture = scrubTexture;
				volumeScrubBeganX = -1;
				_isVolumeScrubbing = false;
			}else if(touch && touch.phase == TouchPhase.MOVED){
				var x:int = globalToLocal(new Point(touch.globalX,touch.globalX-(volumeScrubBeganX))).x - volumeHolder.x;
				if(x < volumeBG.x)
					x = volumeBG.x;
				if(x > (volumeBG.x + volumeBG.width))
					x = volumeBG.x + volumeBG.width;
				volumeScrubImage.x = x;
				var perc:Number = (x - volumeBG.x)/volumeBG.width;
				if(perc > 1.0) perc = 1.0;
				_volume = volumeCurrent.scaleX = perc;
				if(_isMuted) {
					volumeBtn.texture = volumeTexture; 
					_isMuted = false;
				}
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_CONTROLS_SETVOLUME));
			}
		}
		
		protected function onScrubTouch(event:TouchEvent):void {
			var touch:Touch = event.getTouch(scrubImage);
			if(touch != null && touch.phase == TouchPhase.BEGAN){	
				scrubImage.texture = scrubTextureHover;
				_isScrubbing = true;
				scrubBeganX = globalToLocal(new Point(0,touch.globalX)).x-scrubImage.x;	
			}else if(touch != null && touch.phase == TouchPhase.ENDED){
				scrubImage.texture = scrubTexture;
				scrubBeganX = -1;
				_isScrubbing = false;
				event.stopPropagation();
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_CONTROLS_SEEK,{time:proposedTime}));
			}else if(touch && touch.phase == TouchPhase.MOVED){
				var x:int = globalToLocal(new Point(touch.globalX,0)).x;//?
				if(x < progressBG.x)
					x = progressBG.x;
				if(x > (progressAvailable.x + progressAvailable.width))
					x = progressAvailable.x + progressAvailable.width;
				
				
				scrubImage.x = x;
				var perc:Number = (x - progressAvailable.x)/progressBG.width;
				if(perc > 1.0) perc = 1.0;
				proposedTime = duration * perc;
				progressCurrent.scaleX = perc*progressScaleFactor;
				//progressCurrent.width -= 3;
				progressCurrentEndImage.visible = true;
				progressCurrentEndImage.x = progressCurrent.width + progressCurrent.x-1;
				setCurrentTime(proposedTime);
			}
		}
		
		protected function onProgressHover(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(progressHolder);
			if(_isScrubbable){
				if(touch == null || touch.phase == null){
					scrubImage.visible = false;
				}else if(touch != null && touch.phase == TouchPhase.ENDED && !_isScrubbing){
					var x:int = globalToLocal(new Point(touch.globalX-(0),0)).x;
					if(x < progressBG.x) x = progressBG.x;
					if(x > (progressAvailable.x + progressAvailable.width)) x = progressAvailable.x + progressAvailable.width;
					scrubImage.x = x;
					var perc:Number = (x - progressAvailable.x)/progressBG.width;
					proposedTime = duration * perc;
					progressCurrent.scaleX = perc*progressScaleFactor;
					progressCurrentEndImage.visible = true;
					progressCurrentEndImage.x = progressCurrent.width + progressCurrent.x-1;
					this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_CONTROLS_SEEK,{time:proposedTime}));
				}else if(touch != null && touch.phase == TouchPhase.HOVER){
					scrubImage.visible = true;
				}
			}
		}
		
		
		protected function onVolumeScrubHover(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(volumeBG);
			if(touch != null && touch.phase == TouchPhase.ENDED && !_isVolumeScrubbing){
				var x:int = globalToLocal(new Point(touch.globalX-(0),0)).x - volumeHolder.x;
				
				if(x > volumeBG.width + volumeBG.x) x = volumeBG.width + volumeBG.x;
				
				volumeScrubImage.x = x;
				var perc:Number = (x - volumeBG.x)/volumeBG.width;
				if(perc > 1.0) perc = 1.0;
				volumeCurrent.scaleX = perc;
				_volume = volumeCurrent.scaleX = perc;
				if(_isMuted) {
					volumeBtn.texture = volumeTexture; 
					_isMuted = false;
				}
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_CONTROLS_SETVOLUME));
			}
		}
		
		protected function onVolumeHover(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(volumeHolder);
			if(touch == null || touch.phase == null)
				volumeScrubImage.visible = false;
			else if(touch != null && touch.phase == TouchPhase.HOVER)
				volumeScrubImage.visible = true;
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.SPACE && Starling.current.nativeOverlay.stage.focus == null)
				togglePlayPause();
		}
		
		public function updateProgress(_n:Number):void {
			availableProgress = _n;
			/*if(_isScrubbable) */progressAvailable.scaleX = availableProgress*progressScaleFactor;
		}
		
		public function setDuration(n:Number):void {
			duration = n;
			if(!_isLive)
				durationTxt.text = TimeUtils.secsToTimeCode(duration);
		}
		public function setCurrentTime(n:Number):void {
			nCurrentTime = n;
			if(!_isLive){
				timeTxt.text = TimeUtils.secsToTimeCode(nCurrentTime);
				if(nCurrentTime > 0 && duration > 0 && !_isScrubbing/* && _isScrubbable*/){ // not in last 5 seconds
					progressCurrent.scaleX = (nCurrentTime/duration)*progressScaleFactor;
					progressAvailable.visible = progressCurrent.visible = true;
					//trace("scaleX",progressCurrent.scaleX);
					
					progressCurrentEndImage.visible = true;
					progressCurrentEndImage.x = progressCurrent.width + progressCurrent.x-1;
					scrubImage.x = progressCurrent.x + progressCurrent.width+3;
				}
			}
			
		}
		public function setQuality(_s:String):void {
			qualityTxt.text = _s;
		}
		
		public function doResize(_w:int):void{
			w = _w;
			progressScaleFactor = (w-640)/640;
			progressBG.scaleX = progressScaleFactor;
			progressEndRightImage.x = progressBG.x + progressBG.width;
			progressCurrent.scaleX = (nCurrentTime/duration)*progressScaleFactor;
			progressAvailable.scaleX = availableProgress*progressScaleFactor;
			if(_isScrubbable) {
				scrubHit.scaleX = progressScaleFactor;
				scrubImage.x = progressCurrent.x + progressCurrent.width+3;
			}
			durationTxt.x = w-470;
			qualityTxt.x = w-398;
			volumeHolder.x = w-312;
			addBG();
		}
		public function hide():void {
			if(!isHiding && !_isScrubbing && !_isVolumeScrubbing){
				Mouse.hide();
				hideTween = new Tween(holder, 0.25, Transitions.EASE_OUT);
				hideTween.animate("y",52);
				hideTween.onComplete = function():void {
					isHiding = false;
					holder.visible = false;
				}
				Starling.juggler.add(hideTween);
				isHiding = true;
			}
			
		}
		public function show():void {
			holder.visible = true;
			if(!isShowing){
				Mouse.show();
				hideTween = new Tween(holder, 0.25, Transitions.EASE_OUT);
				hideTween.animate("y",0);
				hideTween.onComplete = function():void {
					isShowing = false;
				}
				Starling.juggler.add(hideTween);
			}
			isShowing = true;
		}
		public function reset():void {
			availableProgress = 0;
			progressAvailable.scaleX = 0;
			progressCurrent.scaleX = 0;
			progressAvailable.visible = progressCurrent.visible = false;
			scrubImage.x = progressBG.x;
			durationTxt.text = "";
			timeTxt.text = "";
			qualityTxt.text = "";
			playBtn.visible = false;
			pauseBtn.visible = true;
		}
		
		
		protected function onPlayPauseToggle(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(this);
			if(touch != null && touch.phase == TouchPhase.ENDED)
				togglePlayPause();
		}
		protected function onVolumeToggle(evt:TouchEvent):void {
			var touch:Touch = evt.getTouch(volumeBtn);
			if(touch != null && touch.phase == TouchPhase.ENDED)
				toggleVolume();
		}
		private function toggleVolume(): void {
			if(_isMuted)
				volumeBtn.texture = volumeTexture;
			else
				volumeBtn.texture = volumeMutedTexture;
			_isMuted = !_isMuted;
			this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_CONTROLS_MUTE));
		}
		private function togglePlayPause():void {
			if(playBtn.visible){
				playBtn.visible = false;
				pauseBtn.visible = true;
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_CONTROLS_PLAY));
			}else{
				playBtn.visible = true;
				pauseBtn.visible = false;
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_CONTROLS_PAUSE));
			}
		}
		
		private function addBG():void {
			if(holder.contains(bg))
				holder.removeChild(bg);
			if(bg)
				bg.dispose();
			
			bg = new MeshBatch();
			
			var bgGr:Image;
			for (var n:int=0;n < w;n=n+160){
				bgGr = new Image(Assets.getAtlas().getTexture("controls-bg"));
				bgGr.x = n;
				bg.addMesh(bgGr);
			}
			
			//add the dividers
			dividerImage.touchable = false;
			dividerImage.blendMode = BlendMode.NONE;
			dividerImage.x = w-404;
			dividerImage.y = 9;
			bg.addMesh(dividerImage);
			
			dividerImage.x = w-332;
			bg.addMesh(dividerImage);
			
			dividerImage.x = w-206;
			bg.addMesh(dividerImage);
			
			bg.blendMode = BlendMode.NONE;
			bg.touchable = false;
			holder.addChildAt(bg,0);	
		}
		
		public function get isScrubbing():Boolean {
			return _isScrubbing;
		}

		public function set isScrubbable(value:Boolean):void {
			_isScrubbable = value;
		}

		public function get volume():Number {
			return _volume;
		}

		public function get isMuted():Boolean {
			return _isMuted;
		}

		public function get isVolumeScrubbing():Boolean {
			return _isVolumeScrubbing;
		}

		public function set isLive(value:Boolean):void {
			if(value){
				durationTxt.text = "";
				timeTxt.text = "Live";
			}
			_isLive = value;
		}


	}
}