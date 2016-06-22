package views.client {
	import com.tuarua.ffprobe.Probe;
	import events.FormEvent;
	
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import utils.LangUtils;
	
	import views.forms.CheckBox;
	import views.forms.DropDown;

	public class AudioPanel extends Sprite {
		private var bg:QuadBatch = new QuadBatch();
		private var headingHolder:Sprite = new Sprite();
		private var pane:Sprite = new Sprite();
		private var txtHolder:Sprite = new Sprite();
		private var w:int = 1200;
		private var _encoderDataList:Vector.<Object>;
		private var _bitrateDataList:Vector.<Object> = new Vector.<Object>;
		private var _samplerateDataList:Vector.<Object> = new Vector.<Object>;
		private var codecDropdownsVec:Vector.<DropDown> = new Vector.<DropDown>;
		private var sampleDropdownsVec:Vector.<DropDown> = new Vector.<DropDown>;
		private var bitrateDropdownsVec:Vector.<DropDown> = new Vector.<DropDown>;
		private var chkVec:Vector.<CheckBox> = new Vector.<CheckBox>;
		
		
		public function AudioPanel(encoderDataList:Vector.<Object>) {
			super();
			_encoderDataList = encoderDataList;
			
			_bitrateDataList.push({value:-1,label:"copy"});
			_bitrateDataList.push({value:64000,label:"64"});
			_bitrateDataList.push({value:80000,label:"80"});
			_bitrateDataList.push({value:96000,label:"96"});
			_bitrateDataList.push({value:112000,label:"112"});
			_bitrateDataList.push({value:128000,label:"128"});
			_bitrateDataList.push({value:160000,label:"160"});
			_bitrateDataList.push({value:192000,label:"192"});
			_bitrateDataList.push({value:224000,label:"224"});
			_bitrateDataList.push({value:256000,label:"256"});
			_bitrateDataList.push({value:320000,label:"320"});
			_bitrateDataList.push({value:384000,label:"384"});
			_bitrateDataList.push({value:448000,label:"448"});
			
			_samplerateDataList.push({value:22500,label:"22.5k"});
			_samplerateDataList.push({value:44100,label:"44.1k"});
			_samplerateDataList.push({value:48000,label:"48k"});
			_samplerateDataList.push({value:88200,label:"88.2k"});
			_samplerateDataList.push({value:96000,label:"96k"});
		}
		
		public function update(probe:Probe):void {
			if(codecDropdownsVec) codecDropdownsVec.splice(0, codecDropdownsVec.length);
			if(sampleDropdownsVec) sampleDropdownsVec.splice(0, sampleDropdownsVec.length);
			if(bitrateDropdownsVec) bitrateDropdownsVec.splice(0, bitrateDropdownsVec.length);
			if(chkVec) chkVec.splice(0, chkVec.length);
			
			var sourceLbl:TextField;
			var codecLbl:TextField;
			var codecDrop:DropDown;
			var sampleDrop:DropDown;
			var bitrateDrop:DropDown;
			var chk:CheckBox;
			
			for (var i:int=probe.audioStreams.length-1, l:int=-1; i>l; --i){
				sourceLbl = new TextField(120,32,"Source:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
				codecLbl = new TextField(120,32,"Codec:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
				sourceLbl.vAlign = codecLbl.vAlign = VAlign.TOP;
				sourceLbl.hAlign = codecLbl.hAlign = HAlign.LEFT;
				sourceLbl.touchable = codecLbl.touchable = false;
				sourceLbl.batchable = codecLbl.batchable = true;
				if(probe.audioStreams[i].tags && probe.audioStreams[i].tags.hasOwnProperty("language") && probe.audioStreams[i].tags.language)
					sourceLbl.text = (i+1).toString()+". "+LangUtils.getName(probe.audioStreams[i].tags.language);
				else
					sourceLbl.text = (i+1).toString()+". ";
				
				sourceLbl.x = 20;
				sourceLbl.y = (i * 40) + 20;
				addChild(sourceLbl);
				
				_encoderDataList[0].label = "Copy ("+probe.audioStreams[i].codecName.toUpperCase()+")";
				_encoderDataList[0].value = "copy";
				
				codecDrop = new DropDown(120,_encoderDataList);
				codecDrop.id = "codec:"+i.toString();
				codecDrop.addEventListener(FormEvent.CHANGE,onFormChange);
				codecDrop.x = 120;
				codecDrop.y = (i * 40) + 17;
				codecDrop.enable(i==0);
				codecDropdownsVec.push(codecDrop);
				addChild(codecDrop);
				
				_samplerateDataList[0].label = "Copy ("+(probe.audioStreams[i].sampleRate/1000)+"k)";
				_samplerateDataList[0].value = probe.audioStreams[i].sampleRate;
				
				sampleDrop = new DropDown(120,_samplerateDataList);
				sampleDrop.id = "samplerate:"+i.toString();
				sampleDrop.enable(false);
				sampleDrop.addEventListener(FormEvent.CHANGE,onFormChange);
				sampleDrop.x = 320;
				sampleDrop.y = (i * 40) + 17;
				sampleDropdownsVec.push(sampleDrop);
				addChild(sampleDrop);
				
				//trace(probe.audioStreams[i].bitRate);
				if(isNaN(probe.audioStreams[i].bitRate)){
					_bitrateDataList[0].label = "Copy";
					_bitrateDataList[0].value = -1;
				}else{
					_bitrateDataList[0].label = "Copy ("+(Math.floor(probe.audioStreams[i].bitRate/1000))+")";
					_bitrateDataList[0].value = probe.audioStreams[i].bitRate;
				}

				bitrateDrop = new DropDown(120,_bitrateDataList);
				bitrateDrop.id = "bitrate:"+i.toString();
				bitrateDrop.enable(false);
				bitrateDrop.addEventListener(FormEvent.CHANGE,onFormChange);
				bitrateDrop.x = 520;
				bitrateDrop.y = (i * 40) + 17;
				bitrateDropdownsVec.push(bitrateDrop);
				addChild(bitrateDrop);
				
				chk = new CheckBox(i==0);
				chk.id = "chk:"+i.toString();
				chk.addEventListener(FormEvent.CHANGE,onFormChange);
				chk.x = 700;
				chk.y = (i * 40) + 5;
				chkVec.push(chk);
				addChild(chk);
			}
			
			codecDropdownsVec.reverse();
			bitrateDropdownsVec.reverse();
			sampleDropdownsVec.reverse();
			chkVec.reverse();
		}
		private function onFormChange(event:FormEvent):void {
			var index:int;
			if(event.currentTarget is DropDown){
				var dd:DropDown = event.currentTarget as DropDown;
				if(dd.id.split(":")[0] == "codec"){
					index = parseInt(dd.id.split(":")[1]);
					sampleDropdownsVec[index].enable(dd.selected > 0);
					bitrateDropdownsVec[index].enable(dd.selected > 0);
				}
			}else if(event.currentTarget is CheckBox){
				var chk:CheckBox = event.currentTarget as CheckBox;
				index = parseInt(chk.id.split(":")[1]);
				codecDropdownsVec[index].enable(chk.selected);
				sampleDropdownsVec[index].enable(chk.selected && codecDropdownsVec[index].selected > 0);
				bitrateDropdownsVec[index].enable(chk.selected && codecDropdownsVec[index].selected > 0);
			}
			
		}
		
		public function destroy():void {
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			txtHolder.dispose();
		}
		
		public function getSettings():Vector.<Object> {
			var arr:Vector.<Object> = new Vector.<Object>();
		
			var obj:Object;
			for (var i:int=0, l:int=chkVec.length; i<l; ++i){
				if((chkVec[i] as CheckBox).selected){
					obj = new Object();
					obj.sourceIndex = i;
					obj.codec = _encoderDataList[(codecDropdownsVec[i] as DropDown).selected].value;
					obj.bitrate = _bitrateDataList[(bitrateDropdownsVec[i] as DropDown).selected].value;
					obj.samplerate = _samplerateDataList[(sampleDropdownsVec[i] as DropDown).selected].value;
					arr.push(obj);
				}
			}
			return arr;
		}
		
		
		public function clear():void {
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			
		}
		
		public function freeze():void {
		}
		public function unfreeze():void {
		}
		

			
	}
}