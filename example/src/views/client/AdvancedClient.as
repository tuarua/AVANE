package views.client {
	import com.tuarua.AVANE;
	import com.tuarua.ffmpeg.Attachment;
	import com.tuarua.ffmpeg.GlobalOptions;
	import com.tuarua.ffmpeg.InputOptions;
	import com.tuarua.ffmpeg.InputStream;
	import com.tuarua.ffmpeg.Logger;
	import com.tuarua.ffmpeg.MetaData;
	import com.tuarua.ffmpeg.OutputAudioStream;
	import com.tuarua.ffmpeg.OutputOptions;
	import com.tuarua.ffmpeg.OutputVideoStream;
	import com.tuarua.ffmpeg.Overlay;
	import com.tuarua.ffmpeg.X264AdvancedOptions;
	import com.tuarua.ffmpeg.X264Options;
	import com.tuarua.ffmpeg.X265AdvancedOptions;
	import com.tuarua.ffmpeg.X265Options;
	import com.tuarua.ffmpeg.constants.LogLevel;
	import com.tuarua.ffmpeg.constants.X264Advanced;
	import com.tuarua.ffmpeg.constants.X264Preset;
	import com.tuarua.ffmpeg.constants.X264Profile;
	import com.tuarua.ffmpeg.events.FFmpegEvent;
	import com.tuarua.ffmpeg.filters.video.deinterlace;
	import com.tuarua.ffmpeg.filters.video.denoise;
	import com.tuarua.ffmpeg.filters.video.scaleTo;
	import com.tuarua.ffmpeg.gets.AvailableFormat;
	import com.tuarua.ffmpeg.gets.BitStreamFilter;
	import com.tuarua.ffmpeg.gets.Codec;
	import com.tuarua.ffmpeg.gets.Color;
	import com.tuarua.ffmpeg.gets.Decoder;
	import com.tuarua.ffmpeg.gets.Device;
	import com.tuarua.ffmpeg.gets.Encoder;
	import com.tuarua.ffmpeg.gets.Filter;
	import com.tuarua.ffmpeg.gets.HardwareAcceleration;
	import com.tuarua.ffmpeg.gets.Layouts;
	import com.tuarua.ffmpeg.gets.PixelFormat;
	import com.tuarua.ffmpeg.gets.Protocols;
	import com.tuarua.ffmpeg.gets.SampleFormat;
	import com.tuarua.ffprobe.Probe;
	import com.tuarua.ffprobe.events.ProbeEvent;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.text.TextFieldType;
	
	import events.FormEvent;
	import events.InteractionEvent;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	import views.forms.DropDown;
	import views.forms.Input;
	import starling.display.MeshBatch;
	
	public class AdvancedClient extends Sprite {
		private var bg:MeshBatch = new MeshBatch();
		private var bgBottom:MeshBatch = new MeshBatch();
		private var holder:Sprite = new Sprite();
		private var headingHolder:Sprite = new Sprite();
		private var w:int = 1200;
		private var itmHolder:Sprite = new Sprite();
		private var menuItemHolder:Sprite = new Sprite();
		private var menuItemsVec:Vector.<MenuItem> = new Vector.<MenuItem>();
		private var panelsVec:Vector.<Sprite> = new Vector.<Sprite>();
		
		private var selectedId:String;
		private var _selectedMenu:int = 0;

		public var filePathInput:Input;
		public var filePathOutput:Input;
		private var chooseFileIn:Image = new Image(Assets.getAtlas().getTexture("choose-bg"));
		private var chooseFileOut:Image = new Image(Assets.getAtlas().getTexture("choose-bg"));
		private var selectedFile:File = new File();
		private var containerDrop:DropDown;
		private var encodeButton:Image = new Image(Assets.getAtlas().getTexture("encode-button"));
		private var cancelButton:Image = new Image(Assets.getAtlas().getTexture("cancel-encode-button"));
		private var infoButton:Image = new Image(Assets.getAtlas().getTexture("information-button"));
		private var txtHolder:Sprite = new Sprite();
		private var isEncodeEnabled:Boolean = false;
		private var infoPanel:InfoPanel = new InfoPanel();
		private var avANE:AVANE;

		private var containerDataList:Vector.<Object>;

		private var encoders:Vector.<Encoder>;
		private var filters:Vector.<Filter>;
		private var encodingScreen:EncodingScreen = new EncodingScreen();

		public function AdvancedClient(_avANE:AVANE) {
			super();
			avANE = _avANE;
			avANE.setLogLevel(LogLevel.DEBUG);
			avANE.addEventListener(ProbeEvent.ON_PROBE_INFO,onProbeInfo);
			avANE.addEventListener(ProbeEvent.NO_PROBE_INFO,onNoProbeInfo);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_PROGRESS,encodingScreen.onProgress);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_START,onEncodeStart);
			
		
			
			/*
			var codecs:Vector.<Codec> = avANE.getCodecs();
			var decoders:Vector.<Decoder> = avANE.getDecoders();
			var encoders:Vector.<Encoder> = avANE.getEncoders();
			var bsf:Vector.<BitStreamFilter> = avANE.getBitStreamFilters();
			var protocols:Protocols = avANE.getProtocols();
			var colors:Vector.<Color> = avANE.getColors();
			var pixelFormats:Vector.<PixelFormat> = avANE.getPixelFormats();
			var layouts:Layouts = avANE.getLayouts();
			var sampleFormats:Vector.<SampleFormat> = avANE.getSampleFormats();
			var filters:Vector.<Filter> = avANE.getFilters();
			var formats:Vector.<AvailableFormat> = avANE.getAvailableFormats();
			
			
			*/
			var devices:Vector.<Device> = avANE.getDevices();
			
			selectedFile.addEventListener(Event.SELECT, selectFile);
			bg.touchable = false;
			bg.addMesh(new Quad(w,1,0x0D1012));
			var lineLeft:Quad = new Quad(1,153,0x0D1012);
			var lineRight:Quad = new Quad(1,153,0x0D1012);
			var lineBot:Quad = new Quad(w,1,0x0D1012);
			var middle:Quad = new Quad(w-2,153,0x0D1012);
			middle.x = middle.y = lineRight.y = lineLeft.y = 1;
			middle.alpha = 0.92;
			
			lineRight.x = w-1;
			lineBot.y = 154;
			bg.touchable = false;
			bg.addMesh(lineLeft);
			bg.addMesh(lineRight);
			bg.addMesh(lineBot);
			bg.addMesh(middle);
			
			var bmiddle:Quad = new Quad(w-2,308,0x0D1012);
			var blineLeft:Quad = new Quad(1,308,0x0D1012);
			var blineRight:Quad = new Quad(1,308,0x0D1012);
			var blineBot:Quad = new Quad(w,1,0x0D1012);
			bmiddle.alpha = 0.92;
			bmiddle.x = 1;
			blineRight.x = w-1;
			
			blineRight.y = bmiddle.y = 200;
			blineLeft.y = 200;
			blineBot.y = 508;
			bgBottom.addMesh(bmiddle);
			bgBottom.addMesh(blineLeft);
			bgBottom.addMesh(blineRight);
			bgBottom.addMesh(blineBot);
			
			bgBottom.visible = false;
			itmHolder.y = 25;
			
			
			menuItemsVec.push(new MenuItem("Video",0,true));
			menuItemsVec.push(new MenuItem("Audio",1));
			menuItemsVec.push(new MenuItem("Picture",2));
			menuItemsVec.push(new MenuItem("Filters",3));
			menuItemsVec.push(new MenuItem("Overlay",4));
			
			for (var ii:int=0, ll:int=menuItemsVec.length; ii<ll; ++ii){
				menuItemsVec[ii].x = (ii * 122);
				menuItemsVec[ii].addEventListener(InteractionEvent.ON_MENU_ITEM_MENU,onMenuSelect);
				menuItemHolder.addChild(menuItemsVec[ii]);
			}
			menuItemHolder.visible = false;
			menuItemHolder.y = 173;
			
			holder.x = 40;
			holder.y = 20;

			encoders = avANE.getEncoders();
			filters = avANE.getFilters();
			
			var videoEncoderDataList:Vector.<Object> = new Vector.<Object>();
			var audioEncoderDataList:Vector.<Object> = new Vector.<Object>();
			videoEncoderDataList.push({value:"copy",label:"Copy"});
			if(hasEncoder("libx264"))
				videoEncoderDataList.push({value:"libx264",label:"H.264 (x264)"});
			if(hasEncoder("libx265"))
				videoEncoderDataList.push({value:"libx265",label:"H.265 (x265)"});
			//add others qsv, nvenc
			
			
			audioEncoderDataList.push({value:"copy",label:"Copy"});
			if(hasEncoder("aac"))
				audioEncoderDataList.push({value:"aac",label:"AAC"});
			if(hasEncoder("libmp3lame"))
				audioEncoderDataList.push({value:"libmp3lame",label:"MP3"});
			if(hasEncoder("ac3"))
				audioEncoderDataList.push({value:"ac3",label:"AC3"});
			
			panelsVec.push(new VideoPanel(videoEncoderDataList));
			panelsVec.push(new AudioPanel(audioEncoderDataList));
			panelsVec.push(new PicturePanel());
			panelsVec.push(new FiltersPanel());
			panelsVec.push(new OverlayPanel());
			holder.addChild(bg);
			holder.addChild(bgBottom);
			
			for (var j:int=0, l3:int=panelsVec.length; j<l3; ++j){
				panelsVec[j].y = 200;
				panelsVec[j].visible = false;
				holder.addChild(panelsVec[j]);
			}
			
			holder.addChild(itmHolder);
			holder.addChild(headingHolder);
			holder.addChild(menuItemHolder);
			
			filePathInput = new Input(350,"");
			filePathInput.type = TextFieldType.DYNAMIC;
			filePathInput.x = 100;
			filePathInput.y = 20;
			
			filePathOutput = new Input(350,"");
			filePathOutput.addEventListener(FormEvent.CHANGE,onFormChange);
			filePathOutput.type = TextFieldType.DYNAMIC;
			filePathOutput.x = 100;
			filePathOutput.y = 60;
			
			infoButton.x = 500;
			infoButton.y = 20;
			
			infoPanel.addEventListener(InteractionEvent.ON_CLOSE,onInfoClose);
			infoPanel.x = 200;
			infoPanel.y = 100;
			
			chooseFileIn.x = filePathInput.x + filePathInput.width + 8;
			chooseFileIn.y = filePathInput.y;
			chooseFileIn.useHandCursor = false;
			chooseFileIn.blendMode = BlendMode.NONE;
			chooseFileIn.addEventListener(TouchEvent.TOUCH,onInputTouch);
			
			chooseFileOut.x = filePathOutput.x + filePathOutput.width + 8;
			chooseFileOut.y = filePathOutput.y;
			chooseFileOut.useHandCursor = false;
			chooseFileOut.blendMode = BlendMode.NONE;
			chooseFileOut.addEventListener(TouchEvent.TOUCH,onOutputTouch);
			
			holder.addChild(filePathInput);
			holder.addChild(chooseFileIn);
			
			holder.addChild(filePathOutput);
			holder.addChild(chooseFileOut);
			
			containerDataList = new Vector.<Object>();
			containerDataList.push({value:"mp4",label:"MP4"});
			containerDataList.push({value:"mkv",label:"MKV"});
			containerDataList.push({value:"flv",label:"FLV"});
			
			containerDrop = new DropDown(100,containerDataList);
			containerDrop.addEventListener(FormEvent.CHANGE,onFormChange);
			containerDrop.x = 680;
			containerDrop.y = 20;
			
			
			
			
			holder.addChild(containerDrop);
			
			cancelButton.x = encodeButton.x = 840;
			cancelButton.y = encodeButton.y = 14;
			cancelButton.addEventListener(TouchEvent.TOUCH,onCancel);
			cancelButton.visible = false;
			encodeButton.addEventListener(TouchEvent.TOUCH,onEncode);
			encodeButton.alpha = 0.25;
			
			var tf:TextFormat = new TextFormat();
			tf.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,Align.LEFT,Align.TOP);
			var inputLbl:TextField = new TextField(120,32,"Input:");
			var outputLbl:TextField = new TextField(120,32,"Output:");
			var containerLbl:TextField = new TextField(120,32,"Output container:");
			outputLbl.format = inputLbl.format = containerLbl.format = tf;
			
			outputLbl.touchable = inputLbl.touchable = containerLbl.touchable = false;
			outputLbl.batchable = inputLbl.batchable = containerLbl.batchable = true;
			
			outputLbl.x = inputLbl.x = 30;
			containerLbl.x = 560;
			
			inputLbl.y = 23;
			outputLbl.y = 63;
			containerLbl.y = 23;
			
			txtHolder.addChild(inputLbl);
			txtHolder.addChild(outputLbl);
			txtHolder.addChild(containerLbl);
			
			holder.addChild(encodeButton);
			holder.addChild(cancelButton);
			holder.addChild(txtHolder);
			
			encodingScreen.x = (encodeButton.x-encodingScreen.width)/2;
			encodingScreen.y = 16
			holder.addChild(encodingScreen);
			
			infoButton.addEventListener(TouchEvent.TOUCH,onInfoClick);
			infoButton.visible = false;
			holder.addChild(infoButton);
			infoPanel.visible = false;
			holder.addChild(infoPanel);
			
			addChild(holder);
			
		}
		
	
		private function hasEncoder(value:String):Boolean {
			for (var i:int=0, l:int=encoders.length; i<l; ++i){
				if(encoders[i].name == value)
					return true;
			}
			return false;
		}
		
		private function hasFilter(value:String):Boolean {
			for (var i:int=0, l:int=filters.length; i<l; ++i){
				if(filters[i].name == value)
					return true;
			}
			return false;
		}
		
		private function onInfoClose(event:InteractionEvent):void {
			infoPanel.visible = false;	
		}
		protected function onEncodeStart(event:FFmpegEvent):void {
			trace(event);
		}
		protected function onEncodeFinish(event:FFmpegEvent):void {
			trace(event);
			InputStream.clear();
			OutputOptions.clear();
			filePathInput.unfreeze();
			filePathInput.visible = true;
			chooseFileIn.visible = true;
			
			filePathOutput.unfreeze();
			filePathOutput.visible = true;
			chooseFileOut.visible = true;
			
			containerDrop.visible = true;
			txtHolder.visible = true;
			encodeButton.visible = true;
			cancelButton.visible = false;
			encodingScreen.onComplete();
			encodingScreen.show(false);
		}
		protected function onProbeInfo(event:ProbeEvent):void {
			isEncodeEnabled = (filePathOutput.text != "");
			encodeButton.alpha = isEncodeEnabled ? 1.0 : 0.25;
			var probe:Probe = event.params.data as Probe;
			encodingScreen.totalTime = probe.format.duration;
			(panelsVec[0] as VideoPanel).update(probe);
			(panelsVec[1] as AudioPanel).update(probe);
			(panelsVec[2] as PicturePanel).update(probe);
			infoPanel.update(probe);
			infoButton.visible = true;
			bgBottom.visible = true;
			menuItemHolder.visible = true;
			for (var j:int=0, l3:int=panelsVec.length; j<l3; ++j)
				panelsVec[j].visible = (j==0);
			
		}
		protected function onNoProbeInfo(event:ProbeEvent):void {
			trace(event);
		}
		private function onCancel(event:TouchEvent):void {
			var touch:Touch = event.getTouch(cancelButton);
			if(touch != null && touch.phase == TouchPhase.ENDED){
				avANE.cancelEncode();
				InputStream.clear();
				OutputOptions.clear();
			}	
		}
	
		private function onInfoClick(event:TouchEvent):void {
			var touch:Touch = event.getTouch(infoButton);
			if(touch != null && touch.phase == TouchPhase.ENDED)
				infoPanel.visible = true;
		}
		private function onEncode(event:TouchEvent):void {
			var touch:Touch = event.getTouch(encodeButton);
			if(touch != null && touch.phase == TouchPhase.ENDED && isEncodeEnabled){
				infoButton.visible = false;
				var videoSettings:Object = (panelsVec[0] as VideoPanel).getSettings();
				var audioSettings:Vector.<Object> = (panelsVec[1] as AudioPanel).getSettings();
				
				var inputOptions:InputOptions = new InputOptions();
					
				inputOptions.uri = selectedFile.nativePath;
				InputStream.addInput(inputOptions);
				
				
				
				var videoStream:OutputVideoStream = new OutputVideoStream();
				videoStream.sourceIndex = 0;
				videoStream.codec = videoSettings.codec;
				
				if(videoSettings.codec == "libx264"){
					var x264Options:X264Options = new X264Options();
					x264Options.level = videoSettings.level;
					x264Options.preset = videoSettings.preset;
					x264Options.profile = videoSettings.profile;
					x264Options.tune = videoSettings.tune;
					videoStream.encoderOptions = x264Options;

					//var x264AdvancedOptions:X264AdvancedOptions = new X264AdvancedOptions();
					//x264AdvancedOptions.trellis = X264Advanced.TRELLIS_ALWAYS;
					//x264AdvancedOptions.merange = 13;
					//x264AdvancedOptions.psyRd = [1.0,0.15];
					//videoStream.advancedEncOpts = x264AdvancedOptions;
					
				}else if(videoSettings.codec == "libx265"){
					//different
					var x265Options:X265Options = new X265Options();
					x265Options.preset = videoSettings.preset;
					videoStream.encoderOptions = x265Options;
					
					var x265AdvancedOptions:X265AdvancedOptions = new X265AdvancedOptions();
					x265AdvancedOptions.tune = videoSettings.tune;
					x265AdvancedOptions.profile = videoSettings.profile;
					videoStream.advancedEncOpts = x265AdvancedOptions;
				}

				videoStream.crf = videoSettings.crf;
				videoStream.bitrate = videoSettings.bitrate;
				
				var metadata:MetaData = new MetaData();
				metadata.title = "AVANE encoded video";
				metadata.description = "The description";
				metadata.addCustom("custom_meta","This is custom metadata");
				OutputOptions.metadata = metadata;

				var audioStream:OutputAudioStream;
				for (var i:int=0, l:int=audioSettings.length; i<l; ++i){
					audioStream = new OutputAudioStream();
					audioStream.sourceIndex = audioSettings[i].sourceIndex;
					audioStream.codec = audioSettings[i].codec;
					if(audioStream.codec != "copy"){
						if(audioSettings[i].bitrate > -1)
							audioStream.bitrate = audioSettings[i].bitrate;
						
						if(audioSettings[i].samplerate > -1)
							audioStream.samplerate = audioSettings[i].samplerate;
						audioStream.channels = 2;
					}
					OutputOptions.addAudioStream(audioStream);
				}
				
				OutputOptions.addVideoStream(videoStream);
				OutputOptions.fastStart = true;
				
				var ovlay:Overlay = (panelsVec[4] as OverlayPanel).getOverlay();
				if(ovlay && videoSettings.codec != "copy")
					OutputOptions.addOverlay(ovlay);
				
				var resize:Object = (panelsVec[2] as PicturePanel).getResize();
				if(resize && videoSettings.codec != "copy")
					OutputOptions.addVideoFilter(scaleTo(resize.width));

				var denoiseFilter:Array = (panelsVec[3] as FiltersPanel).getDenoise();
				if(hasFilter("hqdn3d") && denoiseFilter && denoiseFilter.length == 4)
					OutputOptions.addVideoFilter(denoise(denoiseFilter[0],denoiseFilter[1],denoiseFilter[2],denoiseFilter[3]));
				
				//OutputOptions.fileSizeLimit = 1024*1024*10; //10MB limit
				OutputOptions.uri = filePathOutput.text;
				
				filePathInput.freeze();
				filePathInput.visible = false;
				chooseFileIn.visible = false;
				
				filePathOutput.freeze();
				filePathOutput.visible = false;
				chooseFileOut.visible = false;
				
				containerDrop.visible = false;
				txtHolder.visible = false;
				encodeButton.visible = false;
				cancelButton.visible = true;
				
				
				encodingScreen.show(true);
				
				avANE.setLogLevel(LogLevel.INFO);
				Logger.enableLogToTextField = false;
				Logger.enableLogToTrace = true;
				Logger.enableLogToFile = false;
				
				avANE.encode();
			}
		}
		
		private function onFormChange(event:FormEvent):void {
			var test:int;
			switch(event.currentTarget){
				case containerDrop:
					
					break;
				case filePathOutput:
					break;
			}
		}
		protected function selectFile(event:Event):void {
			filePathInput.text = selectedFile.nativePath;
			avANE.getProbeInfo(selectedFile.nativePath);
		}
		
		private function onInputTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(chooseFileIn, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)
				selectedFile.browseForOpen("Select video file...");
		}
		private function onOutputTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(chooseFileOut, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED){
				var savePath:String = avANE.saveAs(containerDataList[containerDrop.selected].value);
				filePathOutput.text = savePath;
				
				isEncodeEnabled = (filePathInput.text != "");
				encodeButton.alpha = isEncodeEnabled ? 1.0 : 0.25;
				
			}
		}
		
		public function get selectedMenu():int {
			return _selectedMenu;
		}

		
		protected function onMenuSelect(event:InteractionEvent):void {
			_selectedMenu = event.params.type;
			
			var mi:MenuItem;
			for (var ii:int=0, ll:int=menuItemsVec.length; ii<ll; ++ii){
				mi = menuItemsVec[ii];
				mi.setSelected((event.params.type == ii));
				panelsVec[ii].visible = (event.params.type == ii);
				if(event.params.type == ii)
					panelsVec[ii].unfreeze();
				else
					panelsVec[ii].freeze();
			}
		}
		protected function onItemSelect(event:InteractionEvent):void {
			trace(event);
		}
		
		public function freeze():void {
			filePathInput.freeze();
			filePathOutput.freeze();
			(panelsVec[0] as VideoPanel).freeze();
			(panelsVec[2] as PicturePanel).freeze();
			(panelsVec[4] as OverlayPanel).freeze();
		}
		public function unfreeze():void {
			filePathInput.unfreeze();
			filePathOutput.unfreeze();
			if((panelsVec[0] as VideoPanel).visible)
				(panelsVec[0] as VideoPanel).unfreeze();
			if((panelsVec[2] as PicturePanel).visible)
				(panelsVec[2] as PicturePanel).unfreeze();
			if((panelsVec[4] as OverlayPanel).visible)
				(panelsVec[4] as OverlayPanel).unfreeze();
		}
		public function suspend():void {
			avANE.removeEventListener(ProbeEvent.ON_PROBE_INFO,onProbeInfo);
			avANE.removeEventListener(ProbeEvent.NO_PROBE_INFO,onNoProbeInfo);
			avANE.removeEventListener(FFmpegEvent.ON_ENCODE_PROGRESS,encodingScreen.onProgress);
			avANE.removeEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
			avANE.removeEventListener(FFmpegEvent.ON_ENCODE_START,onEncodeStart);
			avANE.cancelEncode();
			this.visible = false;
		}
		public function resume():void {
			avANE.addEventListener(ProbeEvent.ON_PROBE_INFO,onProbeInfo);
			avANE.addEventListener(ProbeEvent.NO_PROBE_INFO,onNoProbeInfo);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_PROGRESS,encodingScreen.onProgress);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_START,onEncodeStart);
			this.visible = true;
		}
		
	}
}