package com.tuarua.ffmpeg {
	import com.tuarua.ffmpeg.constants.X264Advanced;
	[RemoteClass(alias="com.tuarua.ffmpeg.X264AdvancedOptions")]
	public class X264AdvancedOptions extends Object {
		//-x264opts keyint=123:min-keyint=20
		public var type:String = "x264-params";
		//public var keyInt:int = 250;
		//public var minKeyInt:int = -1;
		//public var noSceneCut:Boolean = false;
		//public var sceneCut:int = 40;
		//public var intraRefresh:Boolean = false;
		public var bFrames:int = 3;
		public var bAdapt:int = X264Advanced.BADAPT_FAST;
		//public var bBias:int = 0;
		public var bPyramid:String = X264Advanced.BPYRAMID_NORMAL;
		//public var openGop:Boolean = false;
		public var noCabac:Boolean = false;
		
		public var ref:int = 3;
		//public var noDeblock:Boolean = false;
		public var deblock:Array = [0,0];
		//public var slices:int = -1;
		//public var slicesMax:int = -1;
		//public var slicesMaxSize:int = -1;
		//public var slicesMaxMbs:int = -1;
		//public var slicesMinMbs:int = -1;
		//public var tff:Boolean = false;
		//public var bff:Boolean = false;
		//public var constrainedIntra:Boolean = false;
		
		//public var pulldown:String; /*- none, 22, 32, 64, double, triple, euro (requires cfr input)*/
		
		//public var fakeInterlaced:Boolean = false;
		//public var framePacking:int = -1; //0-5
		//public var qp:int = -1; //0-69 //common
		//public var bitrate:int = -1;//(kbit/s)
		//public var crf:int = -1;//0-51 //common
		//public var rcLookahead:int = 40;
		public var vbvMaxRate:int = 0;
		public var vbvBufSize:int = 0;
		//public var vbvInit:Number = 0.9;
		//public var crfMax:Number = -1.0;
		//public var qpMin:int = 0;
		//public var qpMax:int = 69;
		//public var qpStep:int = 4;
		//public var rateTol:Number = 1.0;
		//public var ipRatio:Number = 1.4;
		//public var pbRatio:Number = 1.3;
		//public var chromaqppOffset:int = 0;
		//public var aqMode:int = 1;/* - 0: Disabled, - 1: Variance AQ (complexity mask), - 2: Auto-variance AQ (experimental)*/
		public var aqStrength:Number = 1.0;
		//public var pass:int = 1;/*- 1: First pass, creates stats file, - 2: Last pass, does not overwrite stats file, - 3: Nth pass, overwrites stats file*/
		//public var stats:String;
		//public var noMbTree:Boolean = false;
		//public var qComp:Number = 0.6;
		//public var cplxBlur:Number = 20.0;
		//public var qBlur:Number = 0.5;
		//public var zones:String;
		//public var qpfile:String;
		
		public var partitions:String = X264Advanced.PARTITIONS_MOST;
		public var direct:String = X264Advanced.DIRECT_SPATIAL;
		//public var noWeightB:Boolean = false;
		public var weightP:int = X264Advanced.WEIGHTP_DUPLICATES;
		public var me:String = X264Advanced.ME_HEX;
		public var merange:int = 16;
		//public var mvrange:int = -1;
		//public var mvrangeThread:int = -1;
		public var subme:int = 7;// - 0: fullpel only (not recommended) ,- 1: SAD mode decision, one qpel iteration, - 2: SATD mode decision, - 3-5: Progressively more qpel, - 6: RD mode decision for I/P-frames, - 7: RD mode decision for all frames, - 8: RD refinement for I/P-frames, - 9: RD refinement for all frames, - 10: QP-RD - requires trellis=2, aq-mode>0, - 11: Full RD: disable all early terminations
		public var psyRd:Array = [1.0,0.0];
		//public var noPsy:Boolean = false;
		//public var noMixedRefs:Boolean = false;
		//public var noChromaMe:Boolean = false;
		public var no8x8dct:Boolean = false;
		
		public var trellis:int = X264Advanced.TRELLIS_ENCODE;
		//public var noFastPskip:Boolean = false;
		public var noDctDecimate:Boolean = false;
		//public var nr:int = 0;
		//public var deadzoneInter:int = 21;
		//public var deadzoneIntra:int = 11;
		//public var cqm:String; //jvt, flat
		//public var cqmfile:String;
		
		//public var cqm4:String;
		//public var cqm8:String;
		
		//public var overScan:String = "undef";//undef, show, crop
		//public var videoFormat:String = "undef";//component, pal, ntsc, secam, mac, undef
		//public var range:String = "auto";//auto, tv, pc
		//public var colorPrim:String = "undef";//undef, bt709, bt470m, bt470bg, smpte170m, smpte240m, film, bt2020
		//public var transfer:String = "undef";//undef, bt709, bt470m, bt470bg, smpte170m, smpte240m, linear, log100, log316, iec61966-2-4, bt1361e, iec61966-2-1, bt2020-10, bt2020-12
		
		//public var colorMatrix:String = "undef";// undef, bt709, fcc, bt470bg, smpte170m, smpte240m, GBR, YCgCo, bt2020nc, bt2020c
		
		//public var chromaLoc:int = 0;//0-5
		
		//public var nalHrd:String;//none, vbr, cbr (cbr not allowed in .mp4)
		//public var picStruct:Boolean = false;

		//public var cropRect:String;//left,top,right,bottom

		
		/*
		

		*/
		
		public function X264AdvancedOptions(){}
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function getAsString():String {
			var arr:Array = new Array();
			if(trellis != X264Advanced.TRELLIS_ENCODE)
				arr.push("trellis="+trellis);
			if(merange != 16)
				arr.push("merange="+merange);
			if(ref != 3)
				arr.push("ref="+ref);
			if(bFrames != 3)
				arr.push("bframes="+bFrames);
			if(noCabac)
				arr.push("cabac=0");
			if(no8x8dct)
				arr.push("8x8dct=0");
			if(weightP != X264Advanced.WEIGHTP_DUPLICATES)
				arr.push("weightp="+weightP);
			if(bPyramid != X264Advanced.BPYRAMID_NORMAL)
				arr.push("b-pyramid="+bPyramid);
			if(bAdapt != X264Advanced.BADAPT_FAST)
				arr.push("b-adapt="+bAdapt);
			if(direct != "spatial")
				arr.push("direct="+direct);
			if(me != X264Advanced.ME_HEX)
				arr.push("me="+me);
			if(subme != 7)
				arr.push("subme="+subme);
			if(aqStrength != 1.0)
				arr.push("aq-strength="+aqStrength);
			if(noDctDecimate)
				arr.push("no-dct-decimate=1");
			if(deblock[0] != 0 || deblock[1] != 0)
				arr.push("deblock="+deblock.join(","));
			if(partitions != X264Advanced.PARTITIONS_MOST)
				arr.push("analyse="+partitions);
			if(psyRd[0] != 1.0 || psyRd[1] != 0.0)
				arr.push("psy-rd="+psyRd.join(","));
			
			if(vbvMaxRate > 0)
				arr.push("vbv-maxrate="+vbvMaxRate);
			if(vbvBufSize > 0)
				arr.push("vbv-bufsize="+vbvBufSize);
			
			return arr.join(":");
		}
		
	}
}

//INFO:  [ffmpeg][h264][debug] : user data:"x264 - core 148 r2638 7599210 - H.264/MPEG-4 AVC codec - Copyleft 2003-2015 - http://www.videolan.org/x264.html - options: cabac=1 ref=4 deblock=1:-1:-1 analyse=0x3:0x133 me=umh subme=9 psy=1 psy_rd=1.00:0.15 mixed_ref=1 me_range=16 chroma_me=1 trellis=2 8x8dct=1 cqm=0 deadzone=21,11 fast_pskip=1 chroma_qp_offset=-3 threads=12 lookahead_threads=1 sliced_threads=0 nr=0 decimate=1 interlaced=0 bluray_compat=0 constrained_intra=0 bframes=3 b_pyramid=2 b_adapt=2 b_bias=0 direct=3 weightb=1 open_gop=0 weightp=2 keyint=250 keyint_min=23 scenecut=40 intra_refresh=0 rc_lookahead=60 rc=crf mbtree=1 crf=24.0 qcomp=0.60 qpmin=0 qpmax=69 qpstep=4 ip_ratio=1.40 aq=1:1.00"


/*

Ratecontrol:

--zones <zone0>/<zone1>/...  Tweak the bitrate of regions of the video
Each zone is of the form
<start frame>,<end frame>,<option>
where <option> is either
q=<integer> (force QP)
or  b=<float> (bitrate multiplier)


Analysis:



--cqm4 <list>           Set all 4x4 quant matrices
Takes a comma-separated list of 16 integers.
--cqm8 <list>           Set all 8x8 quant matrices
Takes a comma-separated list of 64 integers.
--cqm4i, --cqm4p, --cqm8i, --cqm8p <list>
Set both luma and chroma quant matrices
--cqm4iy, --cqm4ic, --cqm4py, --cqm4pc <list>
Set individual quant matrices

Video Usability Info (Annex E):
The VUI settings are not used by the encoder but are merely suggestions to
the playback equipment. See doc/vui.txt for details. Use at your own risk.





--chromaloc <integer>   Specify chroma sample location (0 to 5) [0]
--nal-hrd <string>      Signal HRD information (requires vbv-bufsize)
- none, vbr, cbr (cbr not allowed in .mp4)
--pic-struct            Force pic_struct in Picture Timing SEI
--crop-rect <string>    Add 'left,top,right,bottom' to the bitstream-level
cropping rectangle

Input/Output:

-o, --output <string>       Specify output file
--muxer <string>        Specify output container format ["auto"]
- auto, raw, mkv, flv, mp4
--demuxer <string>      Specify input container format ["auto"]
- auto, raw, y4m, avs, lavf, ffms
--input-fmt <string>    Specify input file format (requires lavf support)
--input-csp <string>    Specify input colorspace format for raw input
- valid csps for `raw' demuxer:
i420, yv12, nv12, i422, yv16, nv16, i444, yv24, bgr, bgra, rgb
- valid csps for `lavf' demuxer:
yuv420p, yuyv422, rgb24, bgr24, yuv422p, 
yuv444p, yuv410p, yuv411p, gray, monow, monob, 
pal8, yuvj420p, yuvj422p, yuvj444p, xvmcmc, 
xvmcidct, uyvy422, uyyvyy411, bgr8, bgr4, 
bgr4_byte, rgb8, rgb4, rgb4_byte, nv12, nv21, 
argb, rgba, abgr, bgra, gray16be, gray16le, 
yuv440p, yuvj440p, yuva420p, vdpau_h264, 
vdpau_mpeg1, vdpau_mpeg2, vdpau_wmv3, 
vdpau_vc1, rgb48be, rgb48le, rgb565be, 
rgb565le, rgb555be, rgb555le, bgr565be, 
bgr565le, bgr555be, bgr555le, vaapi_moco, 
vaapi_idct, vaapi_vld, yuv420p16le, 
yuv420p16be, yuv422p16le, yuv422p16be, 
yuv444p16le, yuv444p16be, vdpau_mpeg4, 
dxva2_vld, rgb444le, rgb444be, bgr444le, 
bgr444be, gray8a, bgr48be, bgr48le, yuv420p9be, 
yuv420p9le, yuv420p10be, yuv420p10le, 
yuv422p10be, yuv422p10le, yuv444p9be, 
yuv444p9le, yuv444p10be, yuv444p10le, 
yuv422p9be, yuv422p9le, vda_vld, gbrp, gbrp9be, 
gbrp9le, gbrp10be, gbrp10le, gbrp16be, 
gbrp16le, yuva420p9be, yuva420p9le, 
yuva422p9be, yuva422p9le, yuva444p9be, 
yuva444p9le, yuva420p10be, yuva420p10le, 
yuva422p10be, yuva422p10le, yuva444p10be, 
yuva444p10le, yuva420p16be, yuva420p16le, 
yuva422p16be, yuva422p16le, yuva444p16be, 
yuva444p16le, vdpau, xyz12le, xyz12be, 
rgba64be, rgba64le, bgra64be, bgra64le, 0rgb, 
rgb0, 0bgr, bgr0, yuva444p, yuva422p, 
yuv420p12be, yuv420p12le, yuv420p14be, 
yuv420p14le, yuv422p12be, yuv422p12le, 
yuv422p14be, yuv422p14le, yuv444p12be, 
yuv444p12le, yuv444p14be, yuv444p14le, 
gbrp12be, gbrp12le, gbrp14be, gbrp14le
--output-csp <string>   Specify output colorspace ["i420"]
- i420, i422, i444, rgb
--input-depth <integer> Specify input bit depth for raw input
--input-range <string>  Specify input color range ["auto"]
- auto, tv, pc
--input-res <intxint>   Specify input resolution (width x height)
--index <string>        Filename for input index file
--sar width:height      Specify Sample Aspect Ratio
--fps <float|rational>  Specify framerate
--seek <integer>        First frame to encode
--frames <integer>      Maximum number of frames to encode
--level <string>        Specify level (as defined by Annex A)
--bluray-compat         Enable compatibility hacks for Blu-ray support
--stitchable            Don't optimize headers based on video content
Ensures ability to recombine a segmented encode

-v, --verbose               Print stats for each frame
--no-progress           Don't show the progress indicator while encoding
--quiet                 Quiet Mode
--log-level <string>    Specify the maximum level of logging ["info"]
- none, error, warning, info, debug
--psnr                  Enable PSNR computation
--ssim                  Enable SSIM computation
--threads <integer>     Force a specific number of threads
--lookahead-threads <integer> Force a specific number of lookahead threads
--sliced-threads        Low-latency but lower-efficiency threading
--thread-input          Run Avisynth in its own thread
--sync-lookahead <integer> Number of buffer frames for threaded lookahead
--non-deterministic     Slightly improve quality of SMP, at the cost of repeatability
--cpu-independent       Ensure exact reproducibility across different cpus,
as opposed to letting them select different algorithms
--asm <integer>         Override CPU detection
--no-asm                Disable all CPU optimizations
--opencl                Enable use of OpenCL
--opencl-clbin <string> Specify path of compiled OpenCL kernel cache
--opencl-device <integer>  Specify OpenCL device ordinal
--visualize             Show MB types overlayed on the encoded video
--dump-yuv <string>     Save reconstructed frames
--sps-id <integer>      Set SPS and PPS id numbers [0]
--aud                   Use access unit delimiters
--force-cfr             Force constant framerate timestamp generation
--tcfile-in <string>    Force timestamp generation with timecode file
--tcfile-out <string>   Output timecode v2 file from input timestamps
--timebase <int/int>    Specify timebase numerator and denominator
<integer>    Specify timebase numerator for input timecode file
or specify timebase denominator for other input
--dts-compress          Eliminate initial delay with container DTS hack

Filtering:

--vf, --video-filter <filter0>/<filter1>/... Apply video filtering to the input file

Filter options may be specified in <filter>:<option>=<value> format.

Available filters:
crop:left,top,right,bottom
removes pixels from the edges of the frame
resize:[width,height][,sar][,fittobox][,csp][,method]
resizes frames based on the given criteria:
- resolution only: resizes and adapts sar to avoid stretching
- sar only: sets the sar and resizes to avoid stretching
- resolution and sar: resizes to given resolution and sets the sar
- fittobox: resizes the video based on the desired constraints
- width, height, both
- fittobox and sar: same as above except with specified sar
- csp: convert to the given csp. syntax: [name][:depth]
- valid csp names [keep current]: i420, yv12, nv12, i422, yv16, nv16, i444, yv24, bgr, bgra, rgb
- depth: 8 or 16 bits per pixel [keep current]
note: not all depths are supported by all csps.
- method: use resizer method ["bicubic"]
- fastbilinear, bilinear, bicubic, experimental, point,
- area, bicublin, gauss, sinc, lanczos, spline
select_every:step,offset1[,...]
apply a selection pattern to input frames
step: the number of frames in the pattern
offsets: the offset into the step to select a frame
see: http://avisynth.org/mediawiki/Select#SelectEvery




*/