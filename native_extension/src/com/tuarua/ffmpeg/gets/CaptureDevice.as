package com.tuarua.ffmpeg.gets {
	[RemoteClass(alias="com.tuarua.ffmpeg.gets.CaptureDevice")]
	public class CaptureDevice {
		/** 
		 * <p>Friendly name</p>
		 */	
		public var name:String;
		/** 
		 * <p>Descriptio</p>
		 */	
		public var description:String;
		/** 
		 * <p>"dshow" or "avfoundation"</p>
		 */	
		public var format:String;
		/** 
		 * <p>The device path (if determined) is not intended for display.</p>
		 */	
		public var path:String;
		/** 
		 * <p>Is Audio capture device. A device can be both audio AND video so can appear twice in the list</p>
		 */	
		public var isAudio:Boolean = false;
		/** 
		 * <p>Is Audio video device. A device can be both audio AND video so can appear twice in the list</p>
		 */	
		public var isVideo:Boolean = false;
        /**
         * <p>The index of the device</p>
         */
        public var index:int = 0;
        /**
         * <p>Returns the capabilities of the capture device if available</p>
         */
		public var capabilities:Vector.<CaptureDeviceCapabilities>;
        /**
         * This method is omitted from the output. * * @private
         */
		public function CaptureDevice() {}
	}
}