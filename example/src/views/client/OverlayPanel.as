package views.client {
	import com.tuarua.ffmpeg.Overlay;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.text.TextFieldType;
	
	import events.FormEvent;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Align;
	
	import views.forms.Input;
	import views.forms.Stepper;
	
	public class OverlayPanel extends Sprite {
		public var filePathInput:Input;
		private var chooseFileIn:Image = new Image(Assets.getAtlas().getTexture("choose-bg"));
		private var selectedFile:File;
		private var holder:Sprite = new Sprite();
		private var xStppr:Stepper;
		private var yStppr:Stepper;
		private var inStppr:Stepper;
		private var outStppr:Stepper;
		private var xLbl:TextField = new TextField(32,32,"X:");
		private var yLbl:TextField = new TextField(32,32,"Y:");
		private var inLbl:TextField = new TextField(60,32,"In time:");
		private var outLbl:TextField = new TextField(60,32,"Out time:");
		private var txtHolder:Sprite = new Sprite();
		public function OverlayPanel() {
			super();
			
			var tf:TextFormat = new TextFormat();
			tf.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,Align.LEFT,Align.TOP);
			
			outLbl.format = inLbl.format = yLbl.format = xLbl.format = tf;
			outLbl.touchable = inLbl.touchable = yLbl.touchable = xLbl.touchable = false;
			outLbl.batchable = inLbl.batchable = yLbl.batchable = xLbl.batchable = true;
			
			
			
			xLbl.y = yLbl.y = inLbl.y = outLbl.y = 40;
			
			txtHolder.addChild(xLbl);
			txtHolder.addChild(yLbl);
			txtHolder.addChild(inLbl);
			txtHolder.addChild(outLbl);
			
			selectedFile = new File();
			selectedFile.addEventListener(Event.SELECT, selectFile);
			filePathInput = new Input(350,"");
			filePathInput.type = TextFieldType.DYNAMIC;
			filePathInput.x = 20;
			filePathInput.y = 37;
			filePathInput.unfreeze();
			
			chooseFileIn.x = filePathInput.x + filePathInput.width + 8;
			chooseFileIn.y = filePathInput.y;
			chooseFileIn.useHandCursor = false;
			chooseFileIn.blendMode = BlendMode.NONE;
			chooseFileIn.addEventListener(TouchEvent.TOUCH,onInputTouch);
			
			
			xStppr = new Stepper(65,String(0),4);
			xStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			xStppr.x = chooseFileIn.x + 100;
			xStppr.y = filePathInput.y;
			
			xLbl.x = xStppr.x - 25;
			
			yStppr = new Stepper(65,String(0),4);
			yStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			yStppr.x = xStppr.x + 120;
			yStppr.y = filePathInput.y;
			
			yLbl.x = yStppr.x - 25;
			
			inStppr = new Stepper(65,String(-1),4);
			inStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			inStppr.x = yStppr.x + 200;
			inStppr.y = filePathInput.y;
			
			inLbl.x = inStppr.x - 60;
			
			outStppr = new Stepper(65,String(-1),4);
			outStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			outStppr.x = inStppr.x + 160;
			outStppr.y = filePathInput.y;
			
			outLbl.x = outStppr.x - 65;
			
			filePathInput.freeze();
			xStppr.freeze();
			yStppr.freeze();
			inStppr.freeze();
			outStppr.freeze();
			
			holder.addChild(filePathInput);
			holder.addChild(chooseFileIn);
			holder.addChild(xStppr);
			holder.addChild(yStppr);
			holder.addChild(inStppr);
			holder.addChild(outStppr);
			addChild(holder);
			
			addChild(txtHolder);
			//txtHolder.flatten();
			
		}
		private function onFormChange(event:FormEvent):void {
			var test:int;
			switch(event.currentTarget){
				case xStppr:
					break;
				case yStppr:
					break;
				case inStppr:
					break;
				case outStppr:
					break;
			}
		}
		protected function selectFile(event:Event):void {
			var loaderContext:LoaderContext;
			loaderContext = new LoaderContext();
			loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
			filePathInput.text = selectedFile.nativePath;
			var ldr:Loader = new Loader();
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onImageError);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			ldr.load(new URLRequest(selectedFile.nativePath),loaderContext);
		}
		protected function onImageLoaded(event:Event):void{
			var img:Image = new Image(Texture.fromBitmapData((event.currentTarget.loader.content as Bitmap).bitmapData,false));
			img.x = 20;
			img.y = 90;
			
			addChild(img);
		}
		protected function onImageError(event:IOErrorEvent):void {
			trace(event);
		}
		public function getOverlay():Overlay {
			var ovlay:Overlay;
			if(filePathInput.text.length > 0)
				ovlay = new Overlay(selectedFile.nativePath,xStppr.value,yStppr.value,(inStppr.value > -1) ? inStppr.value : -1,(inStppr.value> -1) ? outStppr.value : -1);
			return ovlay;
		}
		private function onInputTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(chooseFileIn, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)
				selectedFile.browseForOpen("Select image file...",[new FileFilter("image file", "*.png;*.jpg;*.jpeg;*.gif;")]);
		}
		public function freeze():void {
			filePathInput.freeze();
		}
		public function unfreeze():void {
			filePathInput.unfreeze();
		}
		
	}
}