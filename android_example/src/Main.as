package {
	import com.tuarua.AVANE;
	import com.tuarua.ffmpeg.constants.LogLevel;
	import com.tuarua.ffmpeg.events.FFmpegEvent;
	import com.tuarua.ffmpeg.gets.AvailableFormat;
	import com.tuarua.ffmpeg.gets.BitStreamFilter;
	import com.tuarua.ffmpeg.gets.Codec;
	import com.tuarua.ffmpeg.gets.Color;
	import com.tuarua.ffmpeg.gets.Decoder;
	import com.tuarua.ffmpeg.gets.Device;
	import com.tuarua.ffmpeg.gets.Encoder;
	import com.tuarua.ffmpeg.gets.Filter;
	import com.tuarua.ffmpeg.gets.HardwareAcceleration;
	import com.tuarua.ffmpeg.gets.PixelFormat;
	import com.tuarua.ffmpeg.gets.Protocols;
	import com.tuarua.ffmpeg.gets.SampleFormat;
	import com.tuarua.ffprobe.Probe;
	import com.tuarua.ffprobe.events.ProbeEvent;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import utils.TextUtils;
	import utils.TimeUtils;
	
	public class Main extends Sprite {
		private var avANE:AVANE = new AVANE();
		private var btn:Sprite = new Sprite();
		
		public function Main() {
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			btn.graphics.beginFill(0x330033);
			btn.graphics.drawRect(0,0,200,200);
			btn.graphics.endFill();
			btn.addEventListener(MouseEvent.CLICK,onEncodeClick);
			btn.x = 200;
			btn.y = 200;
			
			addChild(btn);
			
			avANE.setLogLevel(LogLevel.INFO);
			trace(avANE.isSupported());
			trace(avANE.getVersion());
			
			trace(avANE.getLicense());
			
			var clrs:Vector.<Color> = avANE.getColors();
			trace("clrs length",clrs.length);
			
			var sampleFormats:Vector.<SampleFormat> = avANE.getSampleFormats();
			
			var protocols:Protocols = avANE.getProtocols();
			
			avANE.addEventListener(ProbeEvent.ON_PROBE_INFO,onProbeInfo);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_START,onEncodeStart);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_FINISH,onEncodeFinish);
			avANE.addEventListener(FFmpegEvent.ON_ENCODE_PROGRESS,onEncodeProgress);
			//avANE.getProbeInfo("http://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4");
			
			//var filters:Vector.<Filter> = avANE.getFilters();
			//var pixelFormats:Vector.<PixelFormat> = avANE.getPixelFormats();
			
			//var bsfs:Vector.<BitStreamFilter> = avANE.getBitStreamFilters();
			
			//var encoders:Vector.<Encoder> = avANE.getEncoders();
			//var decoders:Vector.<Decoder> = avANE.getDecoders();
			
			var hw:Vector.<HardwareAcceleration> = avANE.getHardwareAccelerations();
			
			var codecs:Vector.<Codec> = avANE.getCodecs();
			var devices:Vector.<Device> = avANE.getDevices();
			var availableFormat:Vector.<AvailableFormat> = avANE.getAvailableFormats();
			
		}
		
		protected function onEncodeProgress(event:FFmpegEvent):void {
			trace("time:",TimeUtils.secsToTimeCode((event.params.secs) + (event.params.us/100)));
			trace("frame:",event.params.frame.toString());
			trace("size:",TextUtils.bytesToString(event.params.size*1024));
			trace("bitrate:",event.params.bitrate.toFixed(2)+" Kbps");
			trace("speed:",event.params.speed.toFixed(2)+"x");
			trace("fps:",event.params.fps.toFixed(2));
			trace();
		}
		
		protected function onEncodeFinish(event:FFmpegEvent):void{
			trace(event);
		}
		
		protected function onEncodeStart(event:FFmpegEvent):void {
			trace(event);
		}
		
		protected function onEncodeClick(event:MouseEvent):void {
			avANE.encode("-i http://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4 -c:v libx264 -c:a copy -preset ultrafast -y " + File.documentsDirectory.nativePath + "/AVANEtest.mp4");	
		}
		
		protected function onProbeInfo(event:ProbeEvent):void {
			var probe:Probe = event.params.data as Probe;
			trace();
		}
	}
}