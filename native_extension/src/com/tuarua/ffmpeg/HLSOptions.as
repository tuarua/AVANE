package com.tuarua.ffmpeg {
	public class HLSOptions extends Object {
		/** 
		 * FFmpeg equivalent: -hls_time.
		 * 
		 * <p>Set the target segment length in seconds. Segment will be cut on the next key frame after this time has passed. </p>
		 * @default 2
		 */	
		public var time:int = 2;
		/** 
		 * FFmpeg equivalent: -hls_list_size.
		 * 
		 * <p>Set the maximum number of playlist entries. If set to 0 the list file will contain all the segments.</p>
		 * @default 5
		 */	
		public var listSize:int = 5;
		/** 
		 * FFmpeg equivalent: -hls_wrap.
		 * 
		 * <p>Set the number after which the segment filename number (the number specified in each segment file) wraps. If set to 0 the number will be never wrapped. </p>
		 * <p>This option is useful to avoid to fill the disk with many segment files, and limits the maximum number of segment files written to disk to wrap. </p>
		 * @default 0
		 */	
		public var wrap:int = 0;
		/** 
		 * FFmpeg equivalent: -start_number.
		 * 
		 * <p>Start the playlist sequence number from number. </p>
		 *  
		 * @default 0.0
		 */	
		public var startNumber:Number = 0.0;
		/** 
		 * FFmpeg equivalent: -hls_allow_cache.
		 * 
		 * <p>Explicitly set whether the client MAY (true) or MUST NOT (false) cache media segments. </p>
		 *  
		 * @default false
		 */	
		public var allowCache:Boolean = true;
		/** 
		 * FFmpeg equivalent: -hls_base_url.
		 * 
		 * <p>Append baseurl to every entry in the playlist. Useful to generate playlists with absolute paths. </p>
		 * 
		 * <p>Note that the playlist sequence number must be unique for each segment and it is not to be confused with the segment 
		 * filename sequence number which can be cyclic, for example if the wrap option is specified. </p>
		 *  
		 * @default null which ommits it from the params used 
		 */	
		public var baseUrl:String;
		/** 
		 * FFmpeg equivalent: -hls_segment_filename.
		 * 
		 * <p>Set the segment filename. Unless <code>singleFile</code> is set, filename is used as a string format with the segment number: </p>
		 *  
		 * @default null which ommits it from the params used 
		 */	
		public var segmentFileName:String;
		/** 
		 * FFmpeg equivalent: -use_localtime.
		 * 
		 * <p>Use strftime on filename to expand the segment filename with localtime. The segment number (%d) is not available in this mode. </p>
		 *  
		 * @default false
		 */	
		public var useLocalTime:Boolean = false;
		/** 
		 * FFmpeg equivalent: -use_localtime_mkdir.
		 * 
		 * <p>Used together with useLocalTime, it will create up to one subdirectory which is expanded in filename. </p>
		 *  
		 * @default false
		 */	
		public var useLocalTimeMkdir:Boolean = false;
		/** 
		 * FFmpeg equivalent: -hls_key_info_file.
		 * 
		 * <p>Use the information in key_info_file for segment encryption. The first line of key_info_file specifies the key URI written to the playlist. The key URL is used to access the encryption key during playback. The second line specifies the path to the key file used to obtain the key during the encryption process. The key file is read as a single packed array of 16 octets in binary format. The optional third line specifies the initialization vector (IV) as a hexadecimal string to be used instead of the segment sequence number (default) for encryption. Changes to key_info_file will result in segment encryption with the new key/IV and an entry in the playlist for the new key URI/IV. </p>
		 *  
		 * @default null
		 */	
		public var keyInfoFile:String;
		/** 
		 * FFmpeg equivalent: -hls_flags single_file.
		 * 
		 * <p>If this flag is set, the muxer will store all segments in a single MPEG-TS file, and will use byte ranges in the playlist. 
		 * HLS playlists generated with this way will have the version number 4.</p>
		 *  
		 * @default false
		 */	
		public var singleFile:Boolean = false;
		/** 
		 * FFmpeg equivalent: -hls_flags delete_segments.
		 * 
		 * <p>Segment files removed from the playlist are deleted after a period of time equal to the duration of the segment plus the duration of the playlist. </p>
		 *  
		 * @default false
		 */	
		public var deleteSegments:Boolean = false;
		/** 
		 * FFmpeg equivalent: -hls_playlist_type vod / event.
		 * 
		 * <p>When set to <code>true</code> Emit #EXT-X-PLAYLIST-TYPE:EVENT in the m3u8 header. Forces hls_list_size to 0; the playlist can only be appended to. </p>
		 * <p>When set to <code>false</code> Emit #EXT-X-PLAYLIST-TYPE:VOD in the m3u8 header. Forces hls_list_size to 0; the playlist must not change.</p>
		 * @default false
		 */	
		public var live:Boolean = false;
		/** 
		 * The HLSOptions class is a container class for HLS parameters.
		 * 
		 * <p>An instance of this class can be passed to the OutputOptions.addExtraOptions() method</p>
		 * 
		 * @example The following code shows how:
		 * <listing version="3.0"> 
		 var object:HLSOptions = new HLSOptions();
		 OutputOptions.addExtraOptions(object);
		 </listing>
		 * 
		 * For original FFmpeg documentation visit <a href="https://ffmpeg.org/ffmpeg-all.html#Options-35" target="_blank">https://ffmpeg.org/ffmpeg-all.html#Options-35</a>
		 * 
		 */ 
		public function HLSOptions() {
			super();
		}
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function getAsVector():Vector.<Object> {
			var ret:Vector.<Object> = new Vector.<Object>;
			
			if(time != 2)
				ret.push({"key":"hls_time","value":time.toString()});
			if(listSize != 5)
				ret.push({"key":"hls_list_size","value":listSize.toString()});
			
			if(wrap > 0)
				ret.push({"key":"hls_wrap","value":wrap.toString()});
			
			if(startNumber > 0)
				ret.push({"key":"start_number","value":startNumber.toString()});
			if(baseUrl)
				ret.push({"key":"hls_base_url","value":baseUrl});
			if(allowCache)
				ret.push({"key":"hls_allow_cache","value":(allowCache) ? "1" : "0"});
			if(segmentFileName)
				ret.push({"key":"hls_segment_filename","value":segmentFileName});
			if(useLocalTime)
				ret.push({"key":"use_localtime","value":(useLocalTime) ? "1" : "0"});
			if(useLocalTimeMkdir)
				ret.push({"key":"use_localtime_mkdir","value":(useLocalTimeMkdir) ? "1" : "0"});
			if(keyInfoFile)
				ret.push({"key":"hls_key_info_file","value":keyInfoFile});
			if(singleFile)
				ret.push({"key":"hls_flags","value":"single_file"});
			if(deleteSegments)
				ret.push({"key":"hls_flags","value":"delete_segments"});
			
			ret.push({"key":"hls_playlist_type","value":(live) ? "event" : "vod"});
			
			return ret;
		}
	}
}