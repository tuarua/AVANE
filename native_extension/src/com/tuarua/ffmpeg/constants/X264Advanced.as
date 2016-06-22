package com.tuarua.ffmpeg.constants {
	public class X264Advanced {
		public static const TRELLIS_OFF:int = 0;
		public static const TRELLIS_ENCODE:int = 1;
		public static const TRELLIS_ALWAYS:int = 2;
		
		public static const BADAPT_DISABLED:int = 0;
		public static const BADAPT_FAST:int = 1;
		public static const BADAPT_OPTIMAL:int = 2;
		
		public static const BPYRAMID_DISABLED:String = "none";
		public static const BPYRAMID_STRICT:String = "strict";
		public static const BPYRAMID_NORMAL:String = "normal";
		
		public static const DIRECT_NONE:String = "none";
		public static const DIRECT_SPATIAL:String = "spatial";
		public static const DIRECT_TEMPORAL:String = "temporal";
		public static const DIRECT_AUTO:String = "auto";
		
		public static const PARTITIONS_NONE:String = "none";
		public static const PARTITIONS_ALL:String = "all";
		public static const PARTITIONS_SOME:String = "i4x4,i8x8";
		public static const PARTITIONS_MOST:String = null;
		
		public static const ME_DIAMOND:String = "dia";
		public static const ME_HEX:String = "hex";
		public static const ME_UNEVEN_MULTIHEX:String = "umh";
		public static const ME_EXHAUSTIVE:String = "esa";
		public static const ME_HADAMARD:String = "tesa";
		
		public static const WEIGHTP_DISABLED:int = 0;
		public static const WEIGHTP_REFS:int = 1;
		public static const WEIGHTP_DUPLICATES:int = 2;
	}
}