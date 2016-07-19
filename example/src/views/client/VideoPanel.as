package views.client {
	import com.tuarua.ffmpeg.constants.Nvenc264Preset;
	import com.tuarua.ffmpeg.constants.Nvenc264Profile;
	import com.tuarua.ffmpeg.constants.Nvenc265Preset;
	import com.tuarua.ffmpeg.constants.Nvenc265Profile;
	import com.tuarua.ffmpeg.constants.X264Preset;
	import com.tuarua.ffmpeg.constants.X265Preset;
	
	import com.tuarua.ffmpeg.constants.X264Profile;
	import com.tuarua.ffmpeg.constants.X264Tune;
	import com.tuarua.ffmpeg.constants.X265Profile;
	import com.tuarua.ffmpeg.constants.X265Tune;
	import com.tuarua.ffprobe.Probe;
	
	import events.FormEvent;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	import views.forms.DropDown;
	import views.forms.Input;
	import views.forms.RadioOption;
	import views.forms.Slider;
	
	public class VideoPanel extends Sprite {
		private var txtHolder:Sprite = new Sprite();
		private var _encoderDataList:Vector.<Object>;
		private var _x264PresetDataList:Vector.<Object> = new Vector.<Object>;
		private var _x264ProfileDataList:Vector.<Object> = new Vector.<Object>;
		private var _x264TuneDataList:Vector.<Object> = new Vector.<Object>;
		private var _x264LevelDataList:Vector.<Object> = new Vector.<Object>;
		
		private var _x265ProfileDataList:Vector.<Object> = new Vector.<Object>;
		private var _x265TuneDataList:Vector.<Object> = new Vector.<Object>;
		private var _x265PresetDataList:Vector.<Object> = new Vector.<Object>;
		private var _x265LevelDataList:Vector.<Object> = new Vector.<Object>;
		
		private var _nvenc264PresetDataList:Vector.<Object> = new Vector.<Object>;
		private var _nvenc264ProfileDataList:Vector.<Object> = new Vector.<Object>;
		private var _nvenc264LevelDataList:Vector.<Object> = new Vector.<Object>;
		
		private var _nvenc265PresetDataList:Vector.<Object> = new Vector.<Object>;
		private var _nvenc265ProfileDataList:Vector.<Object> = new Vector.<Object>;
		private var _nvenc265LevelDataList:Vector.<Object> = new Vector.<Object>;
		
		private var presetSlider:Slider = new Slider(18,0,9,5);
		private var crfSlider:Slider = new Slider(5,51,0,20);
		private var codecDrop:DropDown;
		private var profileDrop:DropDown;
		private var tuneDrop:DropDown;
		private var levelDrop:DropDown;
		private var codecLbl:TextField = new TextField(120,32,"Codec:");
		private var presetLbl:TextField = new TextField(120,32,"Preset:");
		private var tuneLbl:TextField = new TextField(120,32,"Tune:");
		private var profileLbl:TextField = new TextField(120,32,"Profile:");
		private var levelLbl:TextField = new TextField(120,32,"Level:");
		private var crfLbl:TextField = new TextField(200,32,"Constant Rate Factor:");
		private var crfTxt:TextField = new TextField(120,32,"20");
		private var presetTxt:TextField = new TextField(200,32,"");
		private var bitrateLbl:TextField = new TextField(200,32,"Bitrate (Kbps):");
		private var crfRadio:RadioOption = new RadioOption(0);
		private var bitrateRadio:RadioOption = new RadioOption(1);
		private var qualityRadioGroupSelected:int=0;
		private var bitrateInput:Input;
		public function VideoPanel(encoderDataList:Vector.<Object>) {
			super();
			_encoderDataList = encoderDataList;
			
			_x264PresetDataList.push({value:X264Preset.ULTRA_FAST,label:"Ultrafast"});
			_x264PresetDataList.push({value:X264Preset.SUPER_FAST,label:"Super Fast"});
			_x264PresetDataList.push({value:X264Preset.VERY_FAST,label:"Very Fast"});
			_x264PresetDataList.push({value:X264Preset.FASTER,label:"Faster"});
			_x264PresetDataList.push({value:X264Preset.FAST,label:"Fast"});
			_x264PresetDataList.push({value:X264Preset.MEDIUM,label:"Medium"});
			_x264PresetDataList.push({value:X264Preset.SLOW,label:"Slow"});
			_x264PresetDataList.push({value:X264Preset.SLOWER,label:"Slower"});
			_x264PresetDataList.push({value:X264Preset.VERY_SLOW,label:"Very Slow"});
			_x264PresetDataList.push({value:X264Preset.PLACEBO,label:"Placebo"});
			
			_x265PresetDataList.push({value:X265Preset.ULTRA_FAST,label:"Ultrafast"});
			_x265PresetDataList.push({value:X265Preset.SUPER_FAST,label:"Super Fast"});
			_x265PresetDataList.push({value:X265Preset.VERY_FAST,label:"Very Fast"});
			_x265PresetDataList.push({value:X265Preset.FASTER,label:"Faster"});
			_x265PresetDataList.push({value:X265Preset.FAST,label:"Fast"});
			_x265PresetDataList.push({value:X265Preset.MEDIUM,label:"Medium"});
			_x265PresetDataList.push({value:X265Preset.SLOW,label:"Slow"});
			_x265PresetDataList.push({value:X265Preset.SLOWER,label:"Slower"});
			_x265PresetDataList.push({value:X265Preset.VERY_SLOW,label:"Very Slow"});
			_x265PresetDataList.push({value:X265Preset.PLACEBO,label:"Placebo"});
			
			_nvenc264PresetDataList.push({value:Nvenc264Preset.LOSSLESS_HIGH_PERFORMANCE,label:"Lossless High Performance"});
			_nvenc264PresetDataList.push({value:Nvenc264Preset.LOSSLESS,label:"Lossless"});
			_nvenc264PresetDataList.push({value:Nvenc264Preset.LOW_LATENCY_HIGH_QUALITY,label:"Low Latency High Quality"});
			_nvenc264PresetDataList.push({value:Nvenc264Preset.LOW_LATENCY,label:"Low Latency"});
			_nvenc264PresetDataList.push({value:Nvenc264Preset.BLURAY,label:"Bluray"});
			_nvenc264PresetDataList.push({value:Nvenc264Preset.HIGH_PERFORMANCE,label:"High Performance"});
			_nvenc264PresetDataList.push({value:Nvenc264Preset.HIGH_QUALITY,label:"High Quality"});
			_nvenc264PresetDataList.push({value:Nvenc264Preset.FAST,label:"Fast"});
			_nvenc264PresetDataList.push({value:Nvenc264Preset.MEDIUM,label:"Medium"});
			_nvenc264PresetDataList.push({value:Nvenc264Preset.SLOW,label:"Slow"});
			
			_nvenc265PresetDataList.push({value:Nvenc265Preset.LOSSLESS_HIGH_PERFORMANCE,label:"Lossless High Performance"});
			_nvenc265PresetDataList.push({value:Nvenc265Preset.LOSSLESS,label:"Lossless"});
			_nvenc265PresetDataList.push({value:Nvenc265Preset.LOW_LATENCY_HIGH_QUALITY,label:"Low Latency High Quality"});
			_nvenc265PresetDataList.push({value:Nvenc265Preset.LOW_LATENCY,label:"Low Latency"});
			_nvenc265PresetDataList.push({value:Nvenc265Preset.BLURAY,label:"Bluray"});
			_nvenc265PresetDataList.push({value:Nvenc265Preset.HIGH_PERFORMANCE,label:"High Performance"});
			_nvenc265PresetDataList.push({value:Nvenc265Preset.HIGH_QUALITY,label:"High Quality"});
			_nvenc265PresetDataList.push({value:Nvenc265Preset.FAST,label:"Fast"});
			_nvenc265PresetDataList.push({value:Nvenc265Preset.MEDIUM,label:"Medium"});
			_nvenc265PresetDataList.push({value:Nvenc265Preset.SLOW,label:"Slow"});

			presetTxt.text = _x264PresetDataList[5].label;
			
			_x264ProfileDataList.push({value:X264Profile.AUTO,label:"Auto"});
			_x264ProfileDataList.push({value:X264Profile.BASELINE,label:"Baseline"});
			_x264ProfileDataList.push({value:X264Profile.MAIN,label:"Main"});
			_x264ProfileDataList.push({value:X264Profile.HIGH,label:"High"});
			
			_x265ProfileDataList.push({value:X265Profile.NONE,label:"Auto"});
			_x265ProfileDataList.push({value:X265Profile.MAIN,label:"Main"});
			_x265ProfileDataList.push({value:X265Profile.MAIN_10,label:"Main 10"});
			_x265ProfileDataList.push({value:X265Profile.MAIN_STILL_PICTURE,label:"MainStillPicure"});
			
			_nvenc264ProfileDataList.push({value:Nvenc264Profile.AUTO,label:"Auto"});
			_nvenc264ProfileDataList.push({value:Nvenc264Profile.BASELINE,label:"Baseline"});
			_nvenc264ProfileDataList.push({value:Nvenc264Profile.MAIN,label:"Main"});
			_nvenc264ProfileDataList.push({value:Nvenc264Profile.HIGH,label:"High"});
			_nvenc264ProfileDataList.push({value:Nvenc264Profile.HIGH_444P,label:"High 444p"});
			
			_nvenc265ProfileDataList.push({value:Nvenc265Profile.MAIN,label:"Main"});
			
			_x264TuneDataList.push({value:"",label:"None"});
			_x264TuneDataList.push({value:X264Tune.FILM,label:"Film"});
			_x264TuneDataList.push({value:X264Tune.ANIMATION,label:"Animation"});
			_x264TuneDataList.push({value:X264Tune.GRAIN,label:"Grain"});
			_x264TuneDataList.push({value:X264Tune.STILL_IMAGE,label:"Still Image"});
			_x264TuneDataList.push({value:X264Tune.PSNR,label:"PSNR"});
			_x264TuneDataList.push({value:X264Tune.SSIM,label:"SSIM"});
			_x264TuneDataList.push({value:X264Tune.FAST_DECODE,label:"Fast Decode"});
			
			_x265TuneDataList.push({value:"",label:"None"});
			_x265TuneDataList.push({value:X265Tune.GRAIN,label:"Grain"});
			_x265TuneDataList.push({value:X265Tune.PSNR,label:"PSNR"});
			_x265TuneDataList.push({value:X265Tune.SSIM,label:"SSIM"});
			_x265TuneDataList.push({value:X265Tune.FAST_DECODE,label:"Fast Decode"});
			_x265TuneDataList.push({value:X265Tune.ZERO_LATENCY,label:"Zero Latency"});
			
			_x264LevelDataList.push({value:"",label:"Auto"});
			_x264LevelDataList.push({value:"1.0",label:"1.0"});
			_x264LevelDataList.push({value:"1b",label:"1b"});
			_x264LevelDataList.push({value:"1.1",label:"1.1"});
			_x264LevelDataList.push({value:"1.2",label:"1.2"});
			_x264LevelDataList.push({value:"1.3",label:"1.3"});
			_x264LevelDataList.push({value:"2.0",label:"2.0"})
			_x264LevelDataList.push({value:"2.1",label:"2.1"})
			_x264LevelDataList.push({value:"2.2",label:"2.2"});
			_x264LevelDataList.push({value:"3.0",label:"3.0"});
			_x264LevelDataList.push({value:"3.1",label:"3.1"});
			_x264LevelDataList.push({value:"3.2",label:"3.2"});
			_x264LevelDataList.push({value:"4.0",label:"4.0"});
			_x264LevelDataList.push({value:"4.1",label:"4.1"});
			_x264LevelDataList.push({value:"4.2",label:"4.2"});
			_x264LevelDataList.push({value:"5.0",label:"5.0"});
			_x264LevelDataList.push({value:"5.1",label:"5.1"});
			_x264LevelDataList.push({value:"5.2",label:"5.2"});
			
			_x265LevelDataList.push({value:"",label:"Auto"});
			_x265LevelDataList.push({value:"1.0",label:"1.0"});
			_x265LevelDataList.push({value:"1b",label:"1b"});
			_x265LevelDataList.push({value:"1.1",label:"1.1"});
			_x265LevelDataList.push({value:"1.2",label:"1.2"});
			_x265LevelDataList.push({value:"1.3",label:"1.3"});
			_x265LevelDataList.push({value:"2.0",label:"2.0"})
			_x265LevelDataList.push({value:"2.1",label:"2.1"})
			_x265LevelDataList.push({value:"2.2",label:"2.2"});
			_x265LevelDataList.push({value:"3.0",label:"3.0"});
			_x265LevelDataList.push({value:"3.1",label:"3.1"});
			_x265LevelDataList.push({value:"3.2",label:"3.2"});
			_x265LevelDataList.push({value:"4.0",label:"4.0"});
			_x265LevelDataList.push({value:"4.1",label:"4.1"});
			_x265LevelDataList.push({value:"4.2",label:"4.2"});
			_x265LevelDataList.push({value:"5.0",label:"5.0"});
			_x265LevelDataList.push({value:"5.1",label:"5.1"});
			_x265LevelDataList.push({value:"5.2",label:"5.2"});
			
			_nvenc264LevelDataList.push({value:"",label:"Auto"});
			_nvenc264LevelDataList.push({value:"1",label:"1"});
			_nvenc264LevelDataList.push({value:"1.0",label:"1.0"});
			_nvenc264LevelDataList.push({value:"1b",label:"1b"});
			_nvenc264LevelDataList.push({value:"1.0b",label:"1.0b"});
			_nvenc264LevelDataList.push({value:"1.1",label:"1.1"});
			_nvenc264LevelDataList.push({value:"1.2",label:"1.2"});
			_nvenc264LevelDataList.push({value:"1.3",label:"1.3"});
			_nvenc264LevelDataList.push({value:"2",label:"2"});
			_nvenc264LevelDataList.push({value:"2.0",label:"2.0"});
			_nvenc264LevelDataList.push({value:"2.1",label:"2.1"});
			_nvenc264LevelDataList.push({value:"2.2",label:"2.2"});
			_nvenc264LevelDataList.push({value:"3",label:"3"});
			_nvenc264LevelDataList.push({value:"3.0",label:"3.0"});
			_nvenc264LevelDataList.push({value:"3.1",label:"3.1"});
			_nvenc264LevelDataList.push({value:"3.2",label:"3.2"});
			_nvenc264LevelDataList.push({value:"4",label:"4"});
			_nvenc264LevelDataList.push({value:"4.0",label:"4.0"});
			_nvenc264LevelDataList.push({value:"4.1",label:"4.1"});
			_nvenc264LevelDataList.push({value:"4.2",label:"4.2"});
			_nvenc264LevelDataList.push({value:"5",label:"5"});
			_nvenc264LevelDataList.push({value:"5.0",label:"5.0"});
			_nvenc264LevelDataList.push({value:"5.1",label:"5.1"});
			
			
			_nvenc265LevelDataList.push({value:"",label:"Auto"});
			_nvenc265LevelDataList.push({value:"1",label:"1"});
			_nvenc265LevelDataList.push({value:"1.0",label:"1.0"});
			_nvenc265LevelDataList.push({value:"2",label:"2"});
			_nvenc265LevelDataList.push({value:"2.0",label:"2.0"});
			_nvenc265LevelDataList.push({value:"2.1",label:"2.1"});
			_nvenc265LevelDataList.push({value:"3",label:"3"});
			_nvenc265LevelDataList.push({value:"3.0",label:"3.0"});
			_nvenc265LevelDataList.push({value:"3.1",label:"3.1"});
			_nvenc265LevelDataList.push({value:"4",label:"4"});
			_nvenc265LevelDataList.push({value:"4.0",label:"4.0"});
			_nvenc265LevelDataList.push({value:"4.1",label:"4.1"});
			_nvenc265LevelDataList.push({value:"5",label:"5"});
			_nvenc265LevelDataList.push({value:"5.0",label:"5.0"});
			_nvenc265LevelDataList.push({value:"5.1",label:"5.1"});
			_nvenc265LevelDataList.push({value:"5.2",label:"5.2"});
			_nvenc265LevelDataList.push({value:"6",label:"6"});
			_nvenc265LevelDataList.push({value:"6.0",label:"6.0"});
			_nvenc265LevelDataList.push({value:"6.1",label:"6.1"});
			_nvenc265LevelDataList.push({value:"6.2",label:"6.2"});
			

			var tf:TextFormat = new TextFormat();
			tf.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,Align.LEFT,Align.TOP);
			
			bitrateLbl.format = crfTxt.format = crfLbl.format = presetTxt.format = profileLbl.format = levelLbl.format = presetLbl.format = codecLbl.format = tuneLbl.format = tf;
			bitrateLbl.touchable = crfTxt.touchable = crfLbl.touchable = presetTxt.touchable = profileLbl.touchable = levelLbl.touchable = presetLbl.touchable = codecLbl.touchable = tuneLbl.touchable = false;
			bitrateLbl.batchable = crfTxt.batchable = crfLbl.batchable = presetTxt.batchable = profileLbl.batchable = levelLbl.batchable = presetLbl.batchable = codecLbl.batchable = tuneLbl.batchable = true;
			
			
			codecLbl.x = 42;
			
			tuneLbl.x = 550;
			presetLbl.x = 550;
			levelLbl.x = 550;
			profileLbl.x = 550;
			
			
			
			levelLbl.y = 100;
			profileLbl.y = 140;
			tuneLbl.y = 180;
			
		

			presetSlider.x = 640;
			codecLbl.y = presetLbl.y = presetSlider.y = 40;
			presetSlider.addEventListener(FormEvent.CHANGE,onFormChange);
			presetSlider.enable(false);
			presetTxt.alpha = presetLbl.alpha = 0.25;
			
			presetTxt.x = presetSlider.x + presetSlider.width + 20;
			presetTxt.y = presetSlider.y;
				
			crfSlider.x = 82;
			crfSlider.y = 150;
			crfSlider.addEventListener(FormEvent.CHANGE,onFormChange);
			crfSlider.enable(false);
			crfTxt.alpha = crfLbl.alpha = 0.25;
			
			bitrateLbl.alpha = 0.25;
			bitrateLbl.x = crfLbl.x = crfSlider.x;
			crfTxt.y = crfLbl.y = crfSlider.y - 30;
			
			crfTxt.x = crfLbl.x + 140;
			
			addChild(presetLbl);
			addChild(codecLbl);
			
			
			addChild(crfLbl);
			addChild(bitrateLbl);
			
			txtHolder.addChild(tuneLbl);
			addChild(levelLbl);
			txtHolder.addChild(profileLbl);
			levelLbl.alpha = txtHolder.alpha = 0.25;
			
			addChild(txtHolder);
			
			
			codecDrop = new DropDown(120,_encoderDataList);
			codecDrop.addEventListener(FormEvent.CHANGE,onFormChange);
			codecDrop.x = 120;
			codecDrop.y = 37;
			
			
			profileDrop = new DropDown(120,_x264ProfileDataList);
			profileDrop.enable(false);
			profileDrop.addEventListener(FormEvent.CHANGE,onFormChange);
			profileDrop.x = 640;
			profileDrop.y = 137;
			
		
			tuneDrop = new DropDown(120,_x264TuneDataList);
			tuneDrop.enable(false);
			tuneDrop.addEventListener(FormEvent.CHANGE,onFormChange);
			tuneDrop.x = 640;
			tuneDrop.y = 177;
			
			levelDrop = new DropDown(120,_x264LevelDataList);
			levelDrop.enable(false);
			levelDrop.addEventListener(FormEvent.CHANGE,onFormChange);
			levelDrop.x = 640;
			levelDrop.y = 97;
			
			addChild(crfSlider);
			addChild(presetSlider);
			addChild(presetTxt);
			addChild(crfTxt);
			
			addChild(tuneDrop);
			addChild(profileDrop);
			addChild(codecDrop);
			addChild(levelDrop);
			
			crfRadio.x = 42;
			crfRadio.y = 118;
			crfRadio.addEventListener(FormEvent.CHANGE,onFormChange);
			crfRadio.enable(false);
			crfRadio.toggle(true);
			addChild(crfRadio);
			
			bitrateRadio.enable(false);
			bitrateRadio.x = 42;
			bitrateRadio.y = 208;
			bitrateLbl.y = bitrateRadio.y + 2;
			
			bitrateInput = new Input(84,"");
			bitrateInput.maxChars = 10;
			bitrateInput.restrict = "0-9";
			
			bitrateInput.addEventListener(FormEvent.CHANGE,onFormChange);
			bitrateInput.freeze();
			bitrateInput.x = 200;
			bitrateInput.y = bitrateLbl.y - 3;
			bitrateInput.enable(false);
			
			bitrateRadio.addEventListener(FormEvent.CHANGE,onFormChange);
			addChild(bitrateRadio);
			addChild(bitrateInput);
		}
		private function onFormChange(event:FormEvent):void {
			var test:int;
			switch(event.currentTarget){
				case presetSlider:
					switch(codecDrop.value){
						case "libx264":
							presetTxt.text = _x264PresetDataList[event.params.value].label;
							break;
						case "h264_nvenc":
							presetTxt.text = _nvenc264PresetDataList[event.params.value].label;
							break;
						case "libx265":
							presetTxt.text = _x265PresetDataList[event.params.value].label;
							break;
						case "hevc_nvenc":
							presetTxt.text = _nvenc265PresetDataList[event.params.value].label;
							break;
						default:
							break;	
					}
					break;
				case crfSlider:
					crfTxt.text = String(event.params.value);
					break;
				case codecDrop:
					switch(event.params.value){
						case "copy":
							bitrateLbl.alpha = crfTxt.alpha = crfLbl.alpha = presetTxt.alpha = presetLbl.alpha = txtHolder.alpha = 0.25;
							crfRadio.enable(false);
							bitrateRadio.enable(false);
							presetSlider.enable(false);
							profileDrop.enable(false);
							tuneDrop.enable(false);
							crfSlider.enable(false);
							bitrateInput.freeze();
							bitrateInput.enable(false);
							levelDrop.enable(false);
							levelLbl.alpha = 0.25;
							break;
						case "libx264":
							presetTxt.alpha = presetLbl.alpha = txtHolder.alpha = 1;
							crfRadio.enable(true);
							bitrateRadio.enable(true);
							presetSlider.enable(true);
							profileDrop.enable(true);
							tuneDrop.enable(true);
							
							crfSlider.enable((qualityRadioGroupSelected == 0));
							crfTxt.alpha = crfLbl.alpha = (qualityRadioGroupSelected == 0) ? 1.0 : 0.25;
							bitrateInput.freeze((qualityRadioGroupSelected == 0));
							bitrateLbl.alpha = (qualityRadioGroupSelected == 0) ? 0.25 : 1.0;
							bitrateInput.enable(!(qualityRadioGroupSelected == 0));
							levelDrop.enable(true);
							levelDrop.update(_x264LevelDataList);
							levelLbl.alpha = 1.0;
							
							profileDrop.update(_x264ProfileDataList);
							tuneDrop.update(_x264TuneDataList);
							
							presetSlider.update(18,0,9,5);
							presetTxt.text = _x264PresetDataList[presetSlider.selected].label;
							
							break;
						case "h264_nvenc":
							presetTxt.alpha = presetLbl.alpha = txtHolder.alpha = 1;
							crfRadio.enable(true);
							bitrateRadio.enable(true);
							presetSlider.enable(true);
							profileDrop.enable(true);
							tuneDrop.enable(false);
							levelDrop.enable(true);
							levelDrop.update(_nvenc264LevelDataList);
							levelLbl.alpha = 1.0;
							
							
							crfSlider.enable((qualityRadioGroupSelected == 0));
							crfTxt.alpha = crfLbl.alpha = (qualityRadioGroupSelected == 0) ? 1.0 : 0.25;
							bitrateInput.freeze((qualityRadioGroupSelected == 0));
							bitrateLbl.alpha = (qualityRadioGroupSelected == 0) ? 0.25 : 1.0;
							bitrateInput.enable(!(qualityRadioGroupSelected == 0));
							levelDrop.enable(true);
							levelLbl.alpha = 1.0;
							
							profileDrop.update(_nvenc264ProfileDataList);
							
							presetSlider.update(18,0,9,8);
							presetTxt.text = _nvenc264PresetDataList[presetSlider.selected].label;
							
							break;
						case "libx265":
							presetTxt.alpha = presetLbl.alpha = txtHolder.alpha = 1;
							crfRadio.enable(true);
							bitrateRadio.enable(true);
							presetSlider.enable(true);
							profileDrop.enable(true);
							tuneDrop.enable(true);
							
							crfSlider.enable((qualityRadioGroupSelected == 0));
							crfTxt.alpha = crfLbl.alpha = (qualityRadioGroupSelected == 0) ? 1.0 : 0.25;
							bitrateInput.freeze((qualityRadioGroupSelected == 0));
							bitrateLbl.alpha = (qualityRadioGroupSelected == 0) ? 0.25 : 1.0;
							bitrateInput.enable(!(qualityRadioGroupSelected == 0));
							levelDrop.enable(true);
							levelDrop.update(_x265LevelDataList);
							levelLbl.alpha = 1.0;
							
							profileDrop.update(_x265ProfileDataList);
							tuneDrop.update(_x265TuneDataList);
							
							presetSlider.update(18,0,9,5);
							presetTxt.text = _x265PresetDataList[presetSlider.selected].label;
							
							break;
						case "hevc_nvenc":
							presetTxt.alpha = presetLbl.alpha = txtHolder.alpha = 1;
							crfRadio.enable(true);
							bitrateRadio.enable(true);
							presetSlider.enable(true);
							profileDrop.enable(true);
							tuneDrop.enable(false);
							levelDrop.enable(true);
							levelDrop.update(_nvenc265LevelDataList);
							levelLbl.alpha = 1.0;
							
							
							crfSlider.enable((qualityRadioGroupSelected == 0));
							crfTxt.alpha = crfLbl.alpha = (qualityRadioGroupSelected == 0) ? 1.0 : 0.25;
							bitrateInput.freeze((qualityRadioGroupSelected == 0));
							bitrateLbl.alpha = (qualityRadioGroupSelected == 0) ? 0.25 : 1.0;
							bitrateInput.enable(!(qualityRadioGroupSelected == 0));
							levelDrop.enable(true);
							levelLbl.alpha = 1.0;
							
							profileDrop.update(_nvenc265ProfileDataList);
							
							presetSlider.update(18,0,9,8);
							presetTxt.text = _nvenc265PresetDataList[presetSlider.selected].label;
							
							break;
					}
						
					break;
				case profileDrop:
					trace(event.params.value);
					break;
				case tuneDrop:
					trace(event.params.value);
					break;
				case levelDrop:
					trace(event.params.value);
					break;
				case crfRadio:
					bitrateRadio.toggle(false);
					qualityRadioGroupSelected = event.params.value;
					crfSlider.enable(true);
					crfTxt.alpha = crfLbl.alpha = 1.0;
					bitrateInput.freeze();
					bitrateInput.enable(false);
					bitrateLbl.alpha = 0.25;
					break;
				case bitrateRadio:
					crfRadio.toggle(false);
					qualityRadioGroupSelected = event.params.value;
					crfSlider.enable(false);
					crfTxt.alpha = crfLbl.alpha = 0.25;
					bitrateInput.freeze(false);
					bitrateInput.enable(true);
					bitrateLbl.alpha = 1.0;
					break;
			}
		}
		
		public function update(probe:Probe):void {
			_encoderDataList[0].label = "Copy ("+probe.videoStreams[0].codecName+")";
			codecDrop.update(_encoderDataList);
		}
		
		public function getSettings():Object {
			var obj:Object = new Object();
			obj.codec = _encoderDataList[codecDrop.selected].value;
			obj.preset = "";
			obj.level = "";
			obj.profile = "";
			obj.tune = "";
			obj.crf = -1;
			obj.bitrate = -1;
			
			switch (codecDrop.value){
				case "libx264":
					obj.preset = _x264PresetDataList[presetSlider.selected].value;
					obj.level = _x264LevelDataList[levelDrop.selected].value;
					obj.profile = _x264ProfileDataList[profileDrop.selected].value;
					obj.tune = _x264TuneDataList[tuneDrop.selected].value;
					break;
				case "h264_nvenc":
					obj.preset = _nvenc264PresetDataList[presetSlider.selected].value;
					obj.level = _nvenc264LevelDataList[levelDrop.selected].value;
					obj.profile = _nvenc264ProfileDataList[profileDrop.selected].value;
					break;
				case "libx265":
					obj.preset = _x265PresetDataList[presetSlider.selected].value;
					obj.level = _x265LevelDataList[levelDrop.selected].value;
					obj.profile = _x265ProfileDataList[profileDrop.selected].value;
					obj.tune = _x265TuneDataList[tuneDrop.selected].value;
					break;
				case "hevc_nvenc":
					obj.preset = _nvenc265PresetDataList[presetSlider.selected].value;
					obj.level = _nvenc265LevelDataList[levelDrop.selected].value;
					obj.profile = _nvenc265ProfileDataList[profileDrop.selected].value;
					break;
				default:
					break;
			}
			
			if(codecDrop.selected > 0){
				if(qualityRadioGroupSelected == 0)
					obj.crf = crfSlider.values[crfSlider.selected];
				else
					obj.bitrate = parseInt(bitrateInput.text)*1000;
			}
			
			/*
			if(codecDrop.selected > 0){
				obj.preset = _x264PresetDataList[presetSlider.selected].value;
				obj.level = _x264LevelDataList[levelDrop.selected].value;
				if(codecDrop.selected == 1){
					obj.profile = _x264ProfileDataList[profileDrop.selected].value;
					obj.tune = _x264TuneDataList[tuneDrop.selected].value;
				}else{
					obj.profile = _x265ProfileDataList[profileDrop.selected].value;
					obj.tune = _x265TuneDataList[tuneDrop.selected].value;
				}
				
				
				
			}
			*/
			return obj;
		}
		public function freeze(value:Boolean=true):void {
			bitrateInput.freeze(value);
		}
		public function clear():void {
			
		}
		
	}
}