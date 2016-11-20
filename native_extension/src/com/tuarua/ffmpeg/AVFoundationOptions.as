package com.tuarua.ffmpeg {
	public class AVFoundationOptions extends Object {
		
		/** 
		 * FFmpeg equivalent: -video_device_index.
		 * 
		 * <p>Specify the video device by its index. Overrides anything given in the input filename. </p>
		 *  
		 * @default -1 which ommits it from the params used 
		 */	
		public var videoDeviceIndex:int = -1;
		/** 
		 * FFmpeg equivalent: -audio_device_index.
		 * 
		 * <p>Specify the audio device by its index. Overrides anything given in the input filename. </p>
		 *  
		 * @default -1 which ommits it from the params used 
		 */	
		public var audioDeviceIndex:int = -1;
		/** 
		 * FFmpeg equivalent: -pixel_format.
		 * 
		 * <p>Request the video device to use a specific pixel format. If the specified format is not supported, a list of available formats is given and the first one in this list is used instead. </p>
		 *  
		 * <p>Available pixel formats are: monob, rgb555be, rgb555le, rgb565be, rgb565le, rgb24, bgr24, 0rgb, bgr0, 0bgr, rgb0, bgr48be, uyvy422, yuva444p, yuva444p16le, yuv444p, yuv422p16, yuv422p10, yuv444p10, yuv420p, nv12, yuyv422, gray</p>
		 * @default null which ommits it from the params used 
		 */	
		public var pixelFormat:String;
		/** 
		 * FFmpeg equivalent: -framerate.
		 * 
		 * <p>Set the grabbing frame rate. Default is ntsc, corresponding to a frame rate of 30000/1001</p>
		 *  
		 * @default 0 which ommits it from the params used 
		 */	
		public var frameRate:Number = 0.0; //
		/** 
		 * FFmpeg equivalent: -video_size.
		 * 
		 * <p>Set the video frame size.</p>
		 *  
		 * @default null which ommits it from the params used 
		 */	
		public var videoSize:String;
		/** 
		 * FFmpeg equivalent: -capture_cursor.
		 * 
		 * <p>Capture the mouse pointer.</p>
		 *  
		 * @default false
		 */	
		public var captureCursor:Boolean = false;
		/** 
		 * FFmpeg equivalent: -capture_mouse_clicks.
		 * 
		 * <p>Capture the screen mouse clicks.</p>
		 *  
		 * @default false
		 */	
		public var captureMouseClicks:Boolean = false;
		/** 
		 * The AVFoundationOptions class is a container class for AVFoundation parameters.
		 * <p>An instance of this class can be passed to the InputOptions.addExtraOptions() method</p>
		 * @example The following code shows how:
		 * <listing version="3.0">
var inputOptions = new InputOptions();
var object:AVFoundationOptions = new AVFoundationOptions();
inputOptions.addExtraOptions(object);
</listing>
		 */ 
		public function AVFoundationOptions() {
			super();
		}
		
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function getAsVector():Vector.<Object> {
			var ret:Vector.<Object> = new Vector.<Object>;
			if(videoDeviceIndex > -1)
				ret.push({"key":"video_device_index","value":videoDeviceIndex.toString()});
			if(audioDeviceIndex > -1)
				ret.push({"key":"video_device_index","value":audioDeviceIndex.toString()});
			if(pixelFormat)
				ret.push({"key":"pixel_format","value":pixelFormat});
			if(frameRate > 0)
				ret.push({"key":"framerate","value":frameRate.toString()});
			if(videoSize)
				ret.push({"key":"video_size","value":videoSize});
			
			ret.push({"key":"capture_cursor","value":(captureCursor) ? "1" : "0"});
			ret.push({"key":"capture_mouse_clicks","value":(captureMouseClicks) ? "1" : "0"});
			
			return ret;
		}
	}
}